import logging
import pathlib
import time
from dataclasses import dataclass

import pexpect

logger = logging.getLogger(__name__)


class Instruction:
    def run(self, script: "Script") -> None:
        logger.info(self.__class__.__name__)


@dataclass
class Script:
    outputfile: pathlib.Path
    asciinema_arguments: str
    wait: float
    delay: float
    standard_deviation: float
    instructions: list[Instruction]
    delaybeforesend = None

    def execute(self) -> None:
        spawn_command = (
            "asciinema rec " + str(self.outputfile) + " " + self.asciinema_arguments
        )
        logger.info(spawn_command)

        try:
            self.process = pexpect.spawn(spawn_command, logfile=None)
            # self.process.logfile = open("pexpect_log.txt", "wb")
            self.process.delaybeforesend = self.delaybeforesend  # type: ignore

            self.process.expect("\n")
            if not (
                f"recording asciicast to {self.outputfile}" in str(self.process.before)
                or f"appending to asciicast at {self.outputfile}"
                in str(self.process.before)
            ):
                self.process.expect(pexpect.EOF)
            else:
                self.process.expect("\n")
                logger.debug(self.process.before)
                logger.debug(self.process.after)
                logger.info("Start reading instructions")
                for instruction in self.instructions:
                    time.sleep(self.wait)
                    instruction.run(self)
                time.sleep(self.wait)
                logger.info("Finished reading instructions")
                self.process.sendcontrol("d")
                self.process.expect(pexpect.EOF)
        finally:
            self.process.close()
            output = self.process.before.decode()
            logger.debug("Output:" + str(output))
            logger.debug("Exit status:" + str(self.process.exitstatus))
            logger.debug("Signal status:" + str(self.process.signalstatus))


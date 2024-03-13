import argparse
import logging
import pathlib
from typing import List, Optional

from asciinema_automation import parse
from asciinema_automation.script import Script


def cli(argv: Optional[List[str]] = None) -> None:
    # Command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "inputfile", help="file containing list of instructions", type=str
    )
    parser.add_argument("outputfile", help="file containing recording", type=str)

    parser.add_argument(
        "-aa",
        "--asciinema-arguments",
        type=str,
        default="",
        help="arguments to be passed to asciinema",
    )
    parser.add_argument(
        "-dt",
        "--delay",
        type=int,
        default=150,
        help="mean for gaussian used to generate time between key strokes",
    )
    parser.add_argument(
        "-wt", "--wait", type=int, default=80, help="time between each instructions"
    )
    parser.add_argument(
        "-sd",
        "--standard-deviation",
        type=int,
        default=60,
        help="""standard deviation for gaussian used to
        generate time between key strokes""",
    )
    parser.add_argument(
        "-t",
        "--timeout",
        type=int,
        default=30,
        help="timeout for a command output to come through",
    )

    # Command line inputs
    args = parser.parse_args(argv)
    inputfile = pathlib.Path(args.inputfile)
    outputfile = pathlib.Path(args.outputfile)
    delay = args.delay
    wait = args.wait
    asciinema_arguments = args.asciinema_arguments
    standard_deviation = args.standard_deviation
    timeout = args.timeout

    # Setup logger
    logging.basicConfig(level=logging.DEBUG)

    # Script
    script = Script(
        outputfile,
        asciinema_arguments,
        wait / 1000,
        delay / 1000,
        standard_deviation / 1000,
        parse.parse_script_file(inputfile, timeout),
    )

    #
    script.execute()

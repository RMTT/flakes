import logging
import sys
import argparse
import subprocess

logger = logging.getLogger(__name__)


def parse_arg():
    parser = argparse.ArgumentParser()
    subparser = parser.add_subparsers(help="subcommands")
    domain_parser = subparser.add_parser("domain")
    ip_parser = subparser.add_parser("ip")

    domain_parser.add_argument("inpath", help="input path")
    domain_parser.add_argument("outpath", help="output path")
    domain_parser.set_defaults(command="domain")

    ip_parser.add_argument("inpath", help="input path")
    ip_parser.add_argument("outpath", help="output path")
    ip_parser.add_argument("-s", "--set", help="full path of nftset", required=True)
    ip_parser.set_defaults(command="ip")

    if len(sys.argv) == 1:
        parser.print_help()
        exit(1)
    return parser.parse_args(sys.argv[1:])


def filter_domain(domain: str):
    if domain.startswith("linkedin"):
        return False
    return True


def fetch_list_from(path: str, callback: callable, timeout=50):
    list = []
    with open(path, "r") as res:
        lines = res.readlines()
        for line in lines:
            r = callback(line)

            if r and len(r) > 0:
                list.append(r)
    return list


def update_chn_domain_list(inpath: str, outpath: str):
    def filter_lines(line: str):
        if line.startswith("#"):
            return None
        if line.find("server=/") != -1:
            elems = line.split("/")
            domain = elems[1]

            return domain

    domains = fetch_list_from(inpath, filter_lines)

    with open(outpath, "wt") as f:
        f.writelines([f"{x}\n" for x in domains if filter_domain(x)])

    logger.info("all done")


def update_chn_ip_list(inpath: str, outpath: str, set_path: str):
    ip_list: list[str] = fetch_list_from(inpath, lambda line: line)
    ip_list = map(lambda line: line.strip() + ",\n", ip_list)

    with open(outpath, "wt") as f:
        f.write("flush set {}\n".format(set_path))
        f.write("add element {} {{\n".format(set_path))
        f.writelines(ip_list)
        f.write("}")


args = parse_arg()

if args.command == "domain":
    update_chn_domain_list(args.inpath, args.outpath)
elif args.command == "ip":
    update_chn_ip_list(args.inpath, args.outpath, args.set)

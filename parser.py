#!/usr/bin/python3

# EE560 GPU ISA Assembler (derived from MIPS32)

# Author: Chang Xu (cxu925@usc.edu)

# Date:    01/10/2020

###

import sys, os

verbose: bool = False

filename: str = ""

InstDict = {
# R-type: (type, opcode, funct)
    "ADD":      (0, 0b000000, 0b100000),
    "SUB":      (0, 0b000000, 0b100010),
    "MUL":      (0, 0b000000, 0b011000),
    "AND":      (0, 0b000000, 0b100100),
    "OR":       (0, 0b000000, 0b100101),
    "XOR":      (0, 0b000000, 0b100110),
    "SHR":      (0, 0b000000, 0b000010),
    "SHL":      (0, 0b000000, 0b000000),
    "DIV":      (0, 0b000000, 0b011010),
# I-type: (type, opcode)
    "ADDI":     (1, 0b001000),
    "ANDI":     (1, 0b001100),
    "ORI":      (1, 0b001101),
    "XORI":     (1, 0b001110),
# LD/ST
    "LD":       (2, 0b100011),
    "LDS":      (2, 0b100111),
    "SW":       (2, 0b101011),
    "SWS":      (2, 0b101111),
# BEQ/BGT
    "BEQ":      (3, 0b000100),
    "BGT":      (3, 0b000111),
# Jump/CALL
    "J":        (4, 0b000010),
    "CALL":     (4, 0b000011),
# RET
    "RET":      (5, 0b000000)
# TODO: ALLOCATE, EXIT, and NOOP
}

class Instruction:
    def __init__(self, raw_instruction: str):
        pass

def errorExit(msg: str, errno: int):
    print("Error: " + msg)
    exit(errno)

def vprint(msg: str):
    if verbose:
        print(msg)

def printUsage():
    print(sys.argv[0] + " <assembly file>")

def processArgs():
    global filename
    if len(sys.argv) < 2:
        printUsage()
        errorExit("ASM file not specified",-1)
    filename = sys.argv[1]
    if not os.path.isfile(filename):
        errorExit(filename + " is not a valid file!", -1)
    fileobj = open(filename, "r")
    vprint(filename + " successfully opened")
    for line in fileobj:
        vprint(line)
    

def main():
    global verbose
    verbose = True
    processArgs()

if __name__ == "__main__":
    main()
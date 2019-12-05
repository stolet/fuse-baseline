import sys
import os
import numpy as np
import re
import pandas as pd

def parse_write(filepath, regx_pattern):
    with open(filepath) as fp:
        vals = np.array([])
        
        for line in fp:
            
            if "write-file" in line:
                opspersec = re.search(regx_pattern, line).group()
                parsedops = opspersec.split("o")[0]
                vals = np.append(vals, float(parsedops))
        
        return np.mean(vals)

def parse_read(filepath, regx_pattern):
    with open(filepath) as fp:

        vals = np.array([])
        for line in fp:
            
            if "read-file" in line:
                opspersec = re.search(regx_pattern, line).group()
                parsedops = opspersec.split("o")[0]
                vals = np.append(vals, float(parsedops))
        
        return np.mean(vals)


def parse_create(filepath, regx_pattern):
    with open(filepath) as fp:

        vals = np.array([])
        for line in fp:
            
            if "create1" in line:
                opspersec = re.search(regx_pattern, line).group()
                parsedops = opspersec.split("o")[0]
                vals = np.append(vals, float(parsedops))
        
        return np.mean(vals)

def parse_delete(filepath, regx_pattern):
    with open(filepath) as fp:

        vals = np.array([])
        for line in fp:
            
            if "delete-file" in line:
                opspersec = re.search(regx_pattern, line).group()
                parsedops = opspersec.split("o")[0]
                vals = np.append(vals, float(parsedops))
        
        return np.mean(vals)

def get_avg(optype, filepath, regx_pattern):
    avg = None
    if "-wr-" in optype:
        avg = parse_write(filepath, regx_pattern)
    elif "-re-" in optype:
        avg = parse_read(filepath, regx_pattern)
    elif "-cr-" in optype:
        avg = parse_create(filepath, regx_pattern)
    elif "-de-" in optype:
        avg = parse_delete(filepath, regx_pattern)
    else:
        print("Unknown parentdir: " + optype)

    return avg

def get_avgs(path, regx_pattern):
    data = {"Type": [], "Workload": [], "Avg": []}
    
    for fsystem in os.listdir(path):
        
        for op_type in os.listdir(path + fsystem + "/"):
            filepath = path + "/" + fsystem + "/" + op_type + "/" + "filebench.out"
            
            if not os.path.isfile(filepath):
                print("File path does not exist: " + filepath)
                sys.exit()
            else:
                avg = get_avg(op_type, filepath, regx_pattern)
                data["Type"].append(fsystem)
                data["Workload"].append(op_type)
                data["Avg"].append(avg)

    return pd.DataFrame(data)

if __name__ == '__main__':
    regx_pattern = "[0-9]*ops\/s"
    path = sys.argv[1]
    parsed_avgs = get_avgs(path, regx_pattern)
    print(parsed_avgs)


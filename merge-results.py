import glob

sourceLocation = "/opt/results/*.jtl"
targetLocation = "/opt/results"
resultFileName = targetLocation + "/mergedResults.jtl"

fileList = glob.glob(sourceLocation)

allLines = []

isFirstFile = True

for fileName in fileList:
    print("=> Reading file:", fileName)

    lines = []

    with open(fileName) as f:
        lines = f.readlines()
        f.close()

    if (isFirstFile): 
        isFirstFile = False
    else:
        lines.remove(lines[0])

    allLines.extend(lines)

print("=> Writing file:", resultFileName)
with open(resultFileName, "w") as f:
    f.writelines(allLines)
    f.close()


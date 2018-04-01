#* Encoding: UTF-8.
begin program.
import spss
import re

# Get the position of the var we care about


def GetVarPosition(Name):
    for ind in range(spss.GetVariableCount()):  # Loop through variable indices
        varNam = spss.GetVariableName(ind)  # Look up each variable name
        if(varNam == Name):
           return ind

# Split the cause up how we need it
def GetPrimaryCause(Case):
    result = re.search('1.(.*)2', Case)
    if(result is None):
        result = re.search('.a\)(.*)\(b\)', Case)
        if(result is None):
            return(Case)
    resultString = (result.group(1).encode('ascii', 'ignore')).strip()
    return(resultString)


def GetSecondaryCause(Case):
    result = re.search('2.(.*)', Case)
    if(result is None):
        result = re.search('.b\)(.*)', Case)
        if(result is None):
            return(result)
    resultString = (result.group(1).encode('ascii', 'ignore')).strip()
    return(resultString)

### MAIN ###
causePosition = GetVarPosition("CAUSE")


# Create new variables
cur = spss.Cursor([causePosition], accessType='w')
cur.SetVarNameAndType(['PrimaryCause', 'SecondaryCause'], [407, 407])
cur.CommitDictionary()

# Loop through our CAUSE cases and assign the causes to the new variables
for i in range(cur.GetCaseCount()):
    oneRow = cur.fetchone()
    oneRowString = ''.join(oneRow)
    primCause = GetPrimaryCause(oneRowString)
    secCause = GetSecondaryCause(oneRowString)

    cur.SetValueChar('PrimaryCause', primCause)

    if(secCause is not None):
        cur.SetValueChar('SecondaryCause', secCause)

    cur.CommitCase()

cur.close()

end program.

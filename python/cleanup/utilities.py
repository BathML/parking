# This python file contains some usefull function (just 1 at the moment)


# This function renames columns in a dataframe
def RenameColumn(DF, oldColumnName, newColumnName):
    if oldColumnName not in DF.columns:
        print('The Data Frame does not contain the column name you specified! Returning the original dataset!')
    else:
        DF.columns = [newColumnName if x==oldColumnName else x for x in DF.columns]
    return DF



# -*- coding: utf-8 -*-
"""
Created on Wed Sep 13 08:54:32 2017

@author: Tatiana Kim
"""



def RenameColumn(DF, oldColumnName, newColumnName):
    if oldColumnName not in DF.columns:
        print('The Data Frame does not contain the column name you specified! Returning the original dataset!')
    else:
        DF.columns = [newColumnName if x==oldColumnName else x for x in DF.columns]
    return DF



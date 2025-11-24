# -*- coding: utf-8 -*-
# x06a_Density_Data_Prep.py
# Description: Prepare density forecasts for performance metric computations.

import pandas as pd
import collections
import math
from collections import defaultdict
import os as OS
import numpy as np
import time

horizonvar = [('Aroll', 'gdp'), ('Broll', 'gdp'), ('Aroll', 'hicp'), ('Broll', 'hicp'), ('Aroll', 'urate'),
              ('Broll', 'urate')]
bcdict = collections.OrderedDict(
    [('gdpAroll', 24), ('gdpBroll', 24), ('gdpfiveyr', 24), ('hicpAroll', 14), ('hicpBroll', 14), ('hicpfiveyr', 14),
     ('urateAroll', 21), ('urateBroll', 21), ('uratefiveyr', 21)])  # bincounts

for horizon, var in horizonvar:

    oldData = pd.read_stata(
        r'...\...\REPLICATION PACKAGE\Data\Intermediate\clean_{}{}_nolowcounts50.dta'.format(
            var, horizon))
    probabilitiesList = ["a" + str(i) for i in range(1, bcdict[str(var) + str(horizon)] + 1)]
    if (var == 'gdp'):  # puts the columns 'a23' and 'a24' in the necessary locations (the columns must be
        # side-by-side), this only needs to be done for GDP
        x = oldData.columns.get_loc('a22')
        a23 = pd.Series(name='a23', dtype=float)
        a24 = pd.Series(name='a24', dtype=float)
        oldData.insert(oldData.columns.get_loc('a22') + 1, 'a23', a23)
        oldData.insert(oldData.columns.get_loc('a22') + 2, 'a24', a24)
    pdfData = oldData.loc[:, probabilitiesList]
    pdfNonNaData = pdfData.fillna(0)
    cumsumData = pdfNonNaData.cumsum(axis=1)
    cumsumData.columns = ["c" + str(i) for i in range(1, bcdict[str(var) + str(horizon)] + 1)]
    currentData = pd.concat([oldData, cumsumData], axis=1)
    print(list(currentData))
    currentData.to_stata(
        r'...\...\REPLICATION PACKAGE\Data\Intermediate\cleanv2_{}{}_nolowcounts50.dta'.format(
            var, horizon))


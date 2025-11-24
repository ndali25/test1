# -*- coding: utf-8 -*-
# x06b_Density_Performance_Metrics.py
# Description: Compute density performance metrics.

import pandas as pd
import collections
import math
from collections import defaultdict
import os as OS
import numpy as np
import time

#### FILL THIS IN ####

start_year = 1999
start_quarter = 1

end_year = 2019
end_quarter = 4


#####################

##### HISTOGRAM CLASS AND RELEVANT METHODS #####

class Histogram:  # this class represents a histogram with bin width of 0.5, although its first and last bins have width 1
    def __init__(self, cdf, startbin, endbin):
        self.cdf = cdf  # dataframe indexed by absolute bin number with interval values and cumulative probabilities
        self.startbin = startbin  # number of first bin
        self.endbin = endbin  # number of last bin
        self.lowbound = cdf.loc[startbin, 'low'] - 0.5  # lower bound of entire distribution (the unit is percentage)
        self.upbound = cdf.loc[endbin, 'high'] + 0.5  # upper bound of entire distribution (the unit is percentage)

    def getVal(self, prob):  # input a probability, and this method returns its corresponding x-value in the CDF
        # if you want to understand the code below (probably not necessary), read the programming appendix
        cdf = self.cdf.copy()
        k = self.startbin

        while (cdf.loc[k, 'probs'] < prob - 0.000001) or (
                cdf.loc[k, 'probs'] < 0.00000001):  # .0000001 is to deal with rounding issues
            k += 1

        if k == self.startbin:
            cdf.loc[k, 'low'] = self.lowbound
            x = self.lowbound + (prob / cdf.loc[self.startbin, 'probs']) * (
                        cdf.loc[self.startbin, 'high'] - self.lowbound)
        else:
            if k == self.endbin:
                x = self.upbound - (1 - prob) / (1 - cdf.loc[self.endbin - 1, 'probs']) * (
                            self.upbound - cdf.loc[self.endbin, 'low'])
            else:
                x = cdf.loc[k, 'low'] + 0.5 * (prob - cdf.loc[k - 1, 'probs']) / (
                            cdf.loc[k, 'probs'] - cdf.loc[k - 1, 'probs'])

        return x

    # Realized Value
    def realizedBin(self, realValue, numOfBins):
        cdf = self.cdf.copy()
        k = self.startbin
        j = 0
        if math.isnan(realValue):
            return [np.nan] * numOfBins
        else:
            # the indicator creation. again, why didn't i use numpy
            indicator = [0] * numOfBins
            lowerBound = self.lowbound
            upperBound = self.upbound
            if (realValue < lowerBound) or (realValue > upperBound):
                j = self.endbin - k + 1
                while (j < numOfBins):
                    # technically the j value is the j+1 place of the list. just writing this so I remember when I am tired
                    indicator[j] = 1
                    j += 1
                return indicator
            else:
                while (cdf.loc[k, 'high'] < realValue) and (k <= self.endbin):
                    if (k == self.endbin) and (realValue <= upperBound):
                        indicator[j] = 1
                    k += 1
                    j += 1
                    if (k > numOfBins) or (k > self.endbin):
                        while (j < numOfBins):
                            indicator[j] = 1
                            j += 1
                        return indicator
                # print("This is k")
                # print(k)
                indicator[j] = 1
                while j < numOfBins:
                    indicator[j] = 1
                    j += 1

                return indicator

    ##IGNORE THIS, remember eada has a better way of calculating this
    def eada(self, realValue):

        # creating thie cdf
        cdf = self.cdf.copy()

        # allocating the current bins
        currentBin = self.startbin
        lowerBound = self.lowbound
        upperBound = self.upbound

        area = 0
        prob = cdf.loc[currentBin, 'probs_dense']

        # calculating the eada area
        if (realValue > lowerBound) and (realValue < cdf.loc[currentBin, 'low']):
            area1 = 0.5 * prob * ((lowerBound - realValue) ** 2)
            area2 = 0.5 * prob * ((realValue - cdf.loc[currentBin, 'low']) ** 2)
            area += (area1 + area2)
        elif (realValue <= lowerBound):
            area += (0.5 * prob * (
            (abs(cdf.loc[currentBin, 'low'] - realValue) ** 2 - abs(lowerBound - realValue) ** 2)))
        else:
            area += (0.5 * prob * (
            (abs(lowerBound - realValue) ** 2 - abs(cdf.loc[currentBin, 'low'] - realValue) ** 2)))

        if math.isnan(area) and math.isnan(prob):
            print("start looking")
            print(area)
            print(prob)

        while (currentBin <= self.endbin):
            prob = cdf.loc[currentBin, 'probs_dense']
            width = cdf.loc[currentBin, 'high'] - cdf.loc[currentBin, 'low']
            if (realValue < cdf.loc[currentBin, 'high']) and (realValue > cdf.loc[currentBin, 'low']):
                area1 = 0.5 * prob * ((cdf.loc[currentBin, 'low'] - realValue) ** 2)
                area2 = 0.5 * prob * ((cdf.loc[currentBin, 'high'] - realValue) ** 2)
                area += (area1 + area2)
            else:
                area += abs(0.5 * prob * (
                (abs(cdf.loc[currentBin, 'low'] - realValue) ** 2 - abs(cdf.loc[currentBin, 'high'] - realValue) ** 2)))
            currentBin += 1

        currentBin -= 1

        if math.isnan(area) or math.isnan(prob):
            print("start looking 2")
            print(area)
            print(prob)

        prob = cdf.loc[currentBin, 'probs_dense']
        if (realValue < upperBound) and (realValue > cdf.loc[currentBin, 'high']):
            area1 = 0.5 * prob * ((cdf.loc[currentBin, 'high'] - realValue) ** 2)
            area2 = 0.5 * prob * ((cdf.loc[currentBin, 'low'] - realValue) ** 2)
            area += (area1 + area2)
        else:
            area += abs(0.5 * prob * (
            (abs(cdf.loc[currentBin, 'low'] - realValue) ** 2 - abs(cdf.loc[currentBin, 'high'] - realValue) ** 2)))

        if math.isnan(area) and math.isnan(prob):
            print("start looking 3")
            print(area)
            print(prob)
            print("")

        return area

    def getCopy(
            self):  # useful in case we re-use specific histograms, as we don't want to alter their contents when we process them
        return Histogram(self.cdf, self.startbin, self.endbin)


def standardize(a,
                b):  # a and b are histograms. This method standardizes their bins if the two histograms have different start and/or end values
    # creates standardized start bins, end bins, and interval widths – with an emphasis on fixing the first and last bins
    histA, histB = a.getCopy(), b.getCopy()  # need to make copies so as not to alter original contents

    if histA.startbin < histB.startbin:  # note that by construction histA.startbin < histB.startbin iff histA.lowbound < histB.lowbound
        histA.startbin = histB.startbin
        histB.lowbound = histA.lowbound
    else:  # in the event histA.startbin = histB.startbin, all of the below values will already be equal, so this does nothing
        histB.startbin = histA.startbin
        histA.lowbound = histB.lowbound

    if histA.endbin > histB.endbin:
        histA.endbin = histB.endbin
        histB.upbound = histA.upbound
    else:
        histB.endbin = histA.endbin
        histA.upbound = histB.upbound

    return [histA, histB]


def getPoints(histA,
              histB):  # returns 1) plist:    the p-values that make up the vector z, as described in the appendix
    #         2) points_a: the one or many x-values of histA.cdf that correspond to each p in plist
    #         3) points_b: the one or many x-values of histB.cdf that correspond to each p in plist

    if (histA.startbin != histB.startbin | histA.endbin != histB.endbin):  # standardize bins if they are not uniform
        histA, histB = standardize(histA, histB)

    plist = [0,
             1]  # plist will eventually be a unique, sorted list of the union of both cdf's cumulative weights, plus the p-values of intersections of cdfs
    # instantiate it with 0 and 1 already in it because the procedure could fail to add these numbers in certain scenarios
    plist_a = histA.cdf['probs']
    plist_b = histB.cdf['probs']
    points_a = defaultdict(
        list)  # these will be filled up with the one or many x-values associated with each p in plist for histA.cdf
    points_b = defaultdict(
        list)  # these will be filled up with the one or many x-values associated with each p in plist for histB.cdf

    for i in range(1,
                   len(plist_a.index) + 1):  # this block rounds all probabilities to fix some floating point arithmetic problems
        plist_a.loc[i] = round(plist_a.loc[i], 7)
    for i in range(1, len(plist_b.index) + 1):
        plist_b.loc[i] = round(plist_b.loc[i], 7)

    points_a[0].append(
        histA.lowbound)  # first entry should be (0: lowbound) corresponding to cumulative prob of 0 placed at the lower bound of distrib.
    points_b[0].append(histB.lowbound)

    for j in range(histA.startbin,
                   histA.endbin):  # note histA.startbin = histB.startbin, same for endbin, by the standardization procedure

        plist.append(plist_a[j]);
        plist.append(plist_b[j])

        points_a[plist_a[j]].append(histA.cdf.loc[j, 'high'])  # stores (p, x) values for histA in a dictionary
        points_b[plist_b[j]].append(histB.cdf.loc[j, 'high'])  # stores (p, x) values for histB in a dictionary

        # the following block adds points at which the two cdf's intersect. See discussion of getPoints() in Programming Appendix
        if abs(plist_a[j] - plist_b[
            j]) > 0.00000001:  # make sure we don't divide by 0, and the 0.00000001 is to deal with floating points

            r = ((plist_a[j + 1] - plist_b[j + 1]) / (
                        plist_a[j] - plist_b[j]))  # if r is negative, then the CDFs MUST cross - think about it

            if r < -.000001:
                r = -r
                p = (plist_a[j + 1] + r * plist_a[j]) / (
                            1 + r)  # this formula spits out the p-value at which the two CDFs cross
                p = round(p, 7)
                plist.append(p)

                # find x-value of this p for both histA and histB and then store in their respective (x, p) dictionaries. note this x is the same for both
                x = (histA.cdf.loc[j + 1, 'high'] + r * histA.cdf.loc[j, 'high']) / (1 + r)

                points_a[p].append(x)
                points_b[p].append(x)
                points_a[p] = sorted(
                    points_a[p])  # sorting is necessary so we can more easily pull out each set's min/max elements
                points_b[p] = sorted(points_b[p])

    points_a[1].append(
        histA.upbound)  # last entry should be (1: upbound) corresponding to cumulative prob of 1 placed at the upper bound of the distribution
    points_b[1].append(histB.upbound)

    for p in plist:  # fills up the points
        if len(points_a[p]) == 0:
            points_a[p].append(histA.getVal(p))
        if len(points_b[p]) == 0:
            points_b[p].append(histB.getVal(p))

    dictionary = {'plist': sorted(set(plist)), 'points_a': points_a, 'points_b': points_b}

    return dictionary  # 'plist' is unique, ordered list of cumulative probabilities that are breakpoints for both histograms
    # 'points_a', 'points_b' are dictionaries of (potentially lists of) (p, x) pairs that are endpoints of intervals that we need to check, for both histograms


def getDistances(histA,
                 histB):  # this method allows us to calculate the Wasserstein and Mallows measures even if a CDF has a flat segment -- see the math appendix
    H = getPoints(histA, histB)
    plist = H['plist']
    points_a = H['points_a']
    points_b = H['points_b']

    L1 = 0
    L2 = 0
    for i in range(1, len(plist)):
        low_a = points_a[plist[i - 1]][
            len(points_a[plist[i - 1]]) - 1]  # pulls the last element in the ordered set (the supremum of the set)
        low_b = points_b[plist[i - 1]][len(points_b[plist[i - 1]]) - 1]
        high_a = points_a[plist[i]][0]  # pulls the first element in the ordered set (the infimum of the set)
        high_b = points_b[plist[i]][0]

        c_a = (high_a + low_a) / 2
        c_b = (high_b + low_b) / 2
        r_a = (high_a - low_a) / 2
        r_b = (high_b - low_b) / 2

        L1 += (plist[i] - plist[i - 1]) * abs((low_a + high_a) / 2 - (low_b + high_b) / 2)
        L2 += (plist[i] - plist[i - 1]) * ((c_a - c_b) ** 2 + (1 / 3) * (r_a - r_b) ** 2)

    return (L1, math.sqrt(L2))


def accuracy(hist, r):  # input a histogram and a realized value "r", outputs the density-based accuracy measure

    # it's easier to work with a PDF than a CDF for this, so these first lines pull the PDF out of the CDF
    pdf = pd.Series(index=hist.cdf.index)
    probs = hist.cdf['probs']
    pdf[1] = probs[1]
    for i in range(2, len(pdf.index) + 1):
        pdf[i] = probs[i] - probs[i - 1]

    L1 = 0
    L2 = 0
    for k in range(hist.startbin, hist.endbin + 1):
        low, high = (hist.cdf.loc[k, 'low'], hist.cdf.loc[k, 'high'])
        if k == hist.startbin:
            low = hist.lowbound
        if k == hist.endbin:
            high = hist.upbound
        if low < r < high:  # if r falls into the bin we're currently at in the loop, we need to use this equation
            x = pdf[k] * ((1 / 2) * (high ** 2 - r ** 2) - r * (high - r)
                          + r * (r - low) - (1 / 2) * (r ** 2 - low ** 2))
        else:
            x = pdf[k] * abs((1 / 2) * (high ** 2 - low ** 2) - r * (high - low))

        L1 += x
        L2 += pdf[k] * ((1 / 3) * (high ** 3 - low ** 3) - r * (high ** 2 - low ** 2) + r ** 2 * (high - low))

    return (L1, math.sqrt(L2))

    ### Analysis Section ###


rootdir = r"...\...\REPLICATION PACKAGE"  # for windows
horizonvar = [('Aroll', 'gdp'), ('Broll', 'gdp'), ('Aroll', 'hicp'), ('Broll', 'hicp'), ('Aroll', 'urate'),
              ('Broll', 'urate')]
# horizonvar = [('Aroll','gdp')]
B = pd.read_excel('{}\Data\Raw\_summary_of_bin_start_and_end_points2.xlsx'.format(rootdir),
                  sheet_name=['bin_range_data', 'starting_bin_data'])
rangeInfo = B['bin_range_data']
binInfo = B['starting_bin_data']
bcdict = collections.OrderedDict(
    [('gdpA', 24), ('gdpAroll', 24), ('gdpB', 24), ('gdpBroll', 24), ('gdpfiveyr', 24), ('hicpA', 14),
     ('hicpAroll', 14), ('hicpB', 14), ('hicpBroll', 14), ('hicpfiveyr', 14), ('urateA', 21), ('urateAroll', 21),
     ('urateB', 21), ('urateBroll', 21), ('uratefiveyr', 21)])
letterDict = {'Aroll': 'A', 'Broll': 'B', 'fiveyr': '5'}

for horizon, var in horizonvar:

    ### Data Prep Work ###

    bc = bcdict['{}{}'.format(var, horizon)]  # bc = bincount

    f_saved = pd.read_stata('{}\Data\Intermediate\cleanv2_{}{}_nolowcounts50.dta'.format(rootdir, var, horizon))

    # if (var=='gdp'): # puts the columns 'a23' and 'a24' in the necessary locations (the columns must be side-by-side), this only needs to be done for GDP
    #     x = f_saved.columns.get_loc('a22')
    #     a23 = pd.Series(name = 'a23')
    #     a24 = pd.Series(name = 'a24')
    #     f_saved.insert(f_saved.columns.get_loc('a22')+1, 'a23', a23)
    #     f_saved.insert(f_saved.columns.get_loc('a22')+2, 'a24', a24)

    f_new = f_saved.copy()

    currentDataSet = []
    binSizeList = []
    eadaList = []
    eadaDf = pd.DataFrame(data=[])

    # cdf is a template that we create now, to be used a lot in the future. check the programming appendix for info
    cdf = rangeInfo.loc[:, ['bin_num', 'low_end_bin_{}'.format(var), 'high_end_bin_{}'.format(var)]]
    cdf.index = cdf['bin_num']
    cdf = cdf.loc[0:bc, :]
    cdf.drop('bin_num', axis=1, inplace=True)
    cdf = cdf.rename(index=str, columns={'low_end_bin_{}'.format(var): 'low', 'high_end_bin_{}'.format(var): 'high'})
    cdf.index = pd.to_numeric(cdf.index)  # fixes a datatype issue with the index

    print(cdf)

    # drops from the dataset certain ydate/qdate combos that have no observations - for instance, uratefiveyr 2000 Q3
    for ydate in range(start_year, end_year + 1):
        for qdate in range(1, 5):
            d = f_saved[(f_saved['ydate'] == ydate) & (f_saved['qdate'] == qdate)]
            if len(d.index) <= 1:
                f_saved = f_saved.drop(d.index)

                ### Disagreement and Accuracy Measures ###

    testingForEqualityOfMatrices = 0
    count = 0  # use this counter to add dictionary entries for each of the ydate/qdate combos
    for ydate in range(start_year, end_year + 1):
        for qdate in range(1, 5):

            if ((ydate == end_year) & (qdate == end_quarter + 1)) | ((ydate == end_year + 1) & (qdate == 1)):
                break  # this stops the loop at end_year/end_quarter

            print()
            print(ydate, qdate)
            f = f_saved.copy()

            bins = binInfo[(binInfo['ydate'] == ydate) & (binInfo['qdate'] == qdate)]
            bins.reset_index(inplace=True)
            startbin = int(bins.loc[0, 'start_bin_{}'.format(
                var)])  # need to cast as an integer because it returns a floating point number
            endbin = int(bins.loc[0, 'end_bin_{}'.format(
                var)])  # note: this analysis is cross-sectional so startbin and endbin are the same for all histograms

            # this is actually not the correct number of bins. it is missing 1 value because the arps measure divides by n-1
            # just easier to keep track of in the program. we deal with this later
            numBins = endbin - startbin

            f = f[(f['ydate'] == ydate) & (f['qdate'] == qdate)]
            N = len(f.index)
            f = f.reset_index()

            print("first end bin: " + str(endbin))
            print("first number of bins: " + str(numBins))

            # apparently most of the time, the right number of bins are specified
            if not f.empty:
                while math.isnan(f.loc[f.index.values[0], 'a{}'.format(numBins + 1)]) and endbin > startbin:
                    numBins = numBins - 1
                    endbin = endbin - 1

                if endbin < bc:
                    while math.isnan(f.loc[f.index.values[0], 'a{}'.format(numBins + 1 + 1)]) == False:
                        numBins = numBins + 1
                        endbin = endbin + 1
                        if endbin == bc:
                            break

            print("changed end bin: " + str(endbin))
            print("changed number of bins: " + str(numBins))
            ###
            ###                   EADA
            ###
            # data set for eada
            dataSetForEADA = f.copy()

            # want to find the extrema of the intervals. Remember that since the open intervals have
            # a width of 1
            intervalExtrema = np.concatenate((np.reshape(cdf.loc[startbin, :].values, (2, 1)) - 0.5, \
                                              np.transpose(cdf.loc[startbin:endbin, :].values), \
                                              np.reshape(cdf.loc[endbin, :].values, (2, 1)) + 0.5), axis=1)
            #            upperIntervalBounds=np.repeat(intervalExtrema[0,:],N,axis=0)
            #            lowerIntervalBounds=np.repeat(intervalExtrema[1,:],N,axis=0)

            # taking the lower and upper intervals of the lower interval bounds
            lowerIntervalBounds = intervalExtrema[0, :].reshape(1, len(intervalExtrema[0, :]))
            lowerIntervalBounds = np.repeat(lowerIntervalBounds, N, axis=0)
            upperIntervalBounds = intervalExtrema[1, :].reshape(1, len(intervalExtrema[1, :]))
            upperIntervalBounds = np.repeat(upperIntervalBounds, N, axis=0)

            # creating vector of realized values
            realizedArray = None

            if var == 'urate':
                realizedArray = np.reshape(f.loc[:, 'realized_urate' + str(letterDict[horizon])].values, (N, 1))
            else:
                realizedArray = np.reshape(f.loc[:, 'realized_{}_growth'.format(var) + str(letterDict[horizon])].values,
                                           (N, 1))

            # print("realized")
            # print(realizedArray)

            # residual difference from the realized value for both the upper and lower values
            upperResidualArray = upperIntervalBounds - realizedArray
            lowerResidualArray = lowerIntervalBounds - realizedArray

            # want to tell whether if the residual is greater or less than 0.
            # The reason for this is that we are taking the integral of f(x)*abs(x-residual)
            # which is just c*abs(x-residual). Note if an the interval contains the realized
            # value (lowerResidual<0) and (upperResidual>0), we need to add the integral of f(x)
            # *abs(x-a) from lowerResidual to realized value and f(x)*abs(x-a) from realized value
            # to upperResidual
            inBin = (lowerResidualArray < 0) * (upperResidualArray > 0)
            eadaWithAddition = inBin.astype(int)
            eadaWithSubtraction = np.logical_not(inBin).astype(int)

            # the array of squared residuals (note this is for the absolute value metric)
            upperResidualArraySq = 0.5 * (upperResidualArray ** 2)
            lowerResidualArraySq = 0.5 * (lowerResidualArray ** 2)

            # the array of cubed residuals (note this is for the squared metric)
            upperResidualArrayCube = (upperResidualArray ** 3) / (3.0)
            lowerResidualArrayCube = (lowerResidualArray ** 3) / (3.0)

            # creating the bin of Probabilities. Note that the first column and
            # last column have repeated probablities since the first and last interval
            # have widths of 1
            binProbs = np.concatenate((np.reshape(f.loc[:, 'a1'].values, (N, 1)), \
                                       f.loc[:, 'a1':'a{}'.format(endbin - startbin + 1)].values, \
                                       np.reshape(f.loc[:, 'a{}'.format(endbin - startbin + 1)].values, (N, 1))),
                                      axis=1)

            # finding the area for the absolute value metric (residuals*probability)
            upperWithProb = upperResidualArraySq * binProbs
            lowerWithProb = lowerResidualArraySq * binProbs

            # finding the area for the squared metric (residuals*probability)
            # note that since this isn't an absolute value fuction, no interval
            # has a non-differentiable point, which means we do not have to worry
            # about splitting an interval
            upperWithProbSqMetric = upperResidualArrayCube * binProbs
            lowerWithProbSqMetric = lowerResidualArrayCube * binProbs
            eadaSqMatrix = upperWithProbSqMetric - lowerWithProbSqMetric

            # calculation for cells where both addition and subtraction should happen
            eadaMatrixWithSubtraction = abs(upperWithProb - lowerWithProb) * eadaWithSubtraction
            eadaMatrixWithAddition = (upperWithProb + lowerWithProb) * eadaWithAddition
            eadaMatrix = eadaMatrixWithSubtraction + eadaMatrixWithAddition

            # putting the EADA in a frame. YAY!
            eada = np.sum(eadaMatrix, axis=1)
            eadaSqMetric = np.sum(eadaSqMatrix, axis=1)
            usedDataSetForEADA = dataSetForEADA.loc[:, ['qdate', 'ydate', 'person']]
            usedDataSetForEADA['EADA'] = pd.Series(eada, index=usedDataSetForEADA.index)
            usedDataSetForEADA['EADA_Sq_Metric'] = pd.Series(eadaSqMetric, index=usedDataSetForEADA.index)
            eadaDf = eadaDf._append(usedDataSetForEADA)


            #############################################################################################

            def createCdf(
                    person):  # returns person's cumulative prob weights indexed by absolute bin numbers, along with the appropriate real number intervals for each bin
                # ALL NEW #
                newcdf = cdf.copy()

                # probs is the cdf value while prods_dense is the pdf value
                newcdf.loc[:startbin,
                'probs'] = 0  # includes startbin just in case startbin==1, so we don't index by startbin-1 = 0, which is out of range
                newcdf.loc[startbin:endbin, 'probs'] = f.loc[person, 'c1':'c{}'.format(endbin - startbin + 1)].values

                newcdf.loc[:,
                'probs_dense'] = 0  # includes startbin just in case startbin==1, so we don't index by startbin-1 = 0, which is out of range
                newcdf.loc[startbin:endbin, 'probs_dense'] = f.loc[person,
                                                             'a1':'a{}'.format(endbin - startbin + 1)].values

                return newcdf

                # ARPS, look at realizedBin def for the function of finding the realized bin


            histDict = {}  # fill up with histograms for each respondent in the current survey
            indicators = {}  # fill up the indicator functions
            binsize = {}
            for i in range(0, N):
                histDict[i] = Histogram(createCdf(i), startbin, endbin)
                if var == 'urate':
                    indicators[i] = histDict[i].realizedBin(f.loc[i, 'realized_urate' + str(letterDict[horizon])], bc)
                    indicators[i].append(int(f.loc[i, 'person']))
                    indicators[i].append(qdate)
                    indicators[i].append(ydate)
                    binsize[i] = []
                    binsize[i].append(numBins)
                    binsize[i].append(int(f.loc[i, 'person']))
                    binsize[i].append(qdate)
                    binsize[i].append(ydate)
                    currentDataSet.append(indicators[i])
                    binSizeList.append(binsize[i])


                else:
                    indicators[i] = histDict[i].realizedBin(
                        f.loc[i, 'realized_{}_growth'.format(var) + str(letterDict[horizon])], bc)
                    indicators[i].append(int(f.loc[i, 'person']))
                    indicators[i].append(qdate)
                    indicators[i].append(ydate)
                    binsize[i] = []
                    binsize[i].append(numBins)

                    binsize[i].append(int(f.loc[i, 'person']))
                    binsize[i].append(qdate)
                    binsize[i].append(ydate)

                    currentDataSet.append(indicators[i])
                    binSizeList.append(binsize[i])

            if var == 'urate':  # "realized" will be the name of the column that contains realized values of each of the three variables
                realized = 'realized_urate' + str(letterDict[horizon])
            else:
                realized = 'realized_{}_growth'.format(var) + str(letterDict[horizon])

            f.index = f[
                'index']  # revert to original indexing so we can properly concatenate across time all of the series containing distance measures

            count += 1

    # reshaping the eada and resorting the index
    eadaDf = eadaDf.sort_values(by=['person', 'ydate', 'qdate'])
    eadaDf = eadaDf.reset_index()
    eadaDf = eadaDf.drop(['index'], axis=1)
    # print(eadaDf)

    currentDataSet = np.array(currentDataSet)
    print("horizon is %r, var is %r" % (horizon, var))
    print(currentDataSet.shape)
    currentDataSet = pd.DataFrame(currentDataSet)
    dataSetNames = ['i' + str(i) for i in range(1, bc + 1)] + ["person", "qdate", "ydate"]
    currentDataSet.columns = dataSetNames
    currentDataSet = currentDataSet.sort_values(by=['person', 'ydate', 'qdate'])
    # print(horizon)
    # print(var)
    # print(currentDataSet)
    f_cums = f_new.loc[:, 'c1':'c{}'.format(bc)];
    f_cums2 = f_new.loc[:, ['person', 'qdate', 'ydate']]
    f_cums = pd.concat([f_cums, f_cums2], axis=1)
    # dataSetNames=['i'+str(i) for i in range(1,bc+1)]+["startbin","endbin","person","qdate","ydate"]
    f_cums_copy = f_cums.copy()
    f_cums_copy = f_cums_copy.dropna(axis=0, subset=['person'])

    currentDataSetCopy = currentDataSet.copy()
    initializedNames = ["i" + str(i) for i in range(1, bc + 1)]
    newNames = {}

    for i in range(1, bc + 1):
        newNames["c" + str(i)] = initializedNames[i - 1]

    f_cums_copy = f_cums_copy.rename(index=str, columns=newNames)
    # f_cums_copy=f_cums_copy.astype('int')
    differenceDataSet = pd.DataFrame(currentDataSetCopy.values - f_cums_copy.values, columns=dataSetNames)
    # print(differenceDataSet)

    binSizeArray = np.array(binSizeList)
    binsizeDataSet = pd.DataFrame(binSizeArray)
    #    binsizeDataSet.columns=["binsize","eada","person","qdate","ydate"]
    binsizeDataSet.columns = ["binsize", "person", "qdate", "ydate"]
    binsizeDataSet = binsizeDataSet.sort_values(by=['person', 'ydate', 'qdate'])
    binsizeDataSet = binsizeDataSet.reset_index()

    print("binsizedata")
    print(binsizeDataSet.loc[:, ['person', 'ydate', 'qdate']].values)
    print("eadaData")
    print(eadaDf.loc[:, ['person', 'ydate', 'qdate']].values)

    print("binsize and eada difference")
    print(sum(binsizeDataSet.loc[:, ['person', 'ydate', 'qdate']].values - eadaDf.loc[:,
                                                                           ['person', 'ydate', 'qdate']].values))

    print("eada type")
    print(type(eadaDf.loc[:, ['EADA', 'EADA_Sq_Metric']]))

    # print("binSize1")
    # print(binsizeDataSet)

    binsizeToDivide = pd.DataFrame(binsizeDataSet.loc[:, 'binsize'], columns=['binsize'])
    # binsizeToDivide=binsizeToDivide.rename(index=str, columns={"binsize":"rank_prob_score_revised"})
    binsizeToDivide = binsizeToDivide.astype('float')

    # For ARPS (non-squared)
    differenceDataSet = differenceDataSet.abs()
    cumSumDifference = differenceDataSet.loc[:, 'i1':'i{}'.format(bc)].sum(axis=1, skipna=False)
    cumSumDifference = cumSumDifference.to_frame(name="rank_prob_score_revised")

    # For ARPS (squared)
    differenceDataSetSq = pd.DataFrame(data=differenceDataSet.values ** 2, columns=differenceDataSet.columns.values)
    cumSumDifferenceSq = differenceDataSetSq.loc[:, 'i1':'i{}'.format(bc)].sum(axis=1, skipna=False)
    cumSumDifferenceSq = cumSumDifferenceSq.to_frame(name="rank_prob_score_squared_revised")

    # dividing the absolute value and squared values
    cumSumDifference = pd.DataFrame(cumSumDifference.values / binsizeToDivide.values,
                                    columns=["rank_prob_score_revised_abs"])
    cumSumDifferenceSq = pd.DataFrame(cumSumDifferenceSq.values / binsizeToDivide.values,
                                      columns=["rank_prob_score_revised_squared"])

    # adding 1 back
    binsizeToDivide = pd.DataFrame(binsizeToDivide.values + 1, columns=["binSize"])
    binsizeToDivide = binsizeToDivide.astype('int')
    # cumSumDifference=cumSumDifference.divide(binsizeToDivide.loc[:,"rank_prob_score_revised"], axis='columns')

    eadaFrameForUse = eadaDf.loc[:, ["EADA", "EADA_Sq_Metric"]]
    eadaFrameForUse.index = binsizeToDivide.index.values

    f_new = f_new.sort_values(['person', 'ydate', 'qdate'])

    f_new = pd.concat([f_new, cumSumDifference, cumSumDifferenceSq, binsizeToDivide, eadaFrameForUse], axis=1)
    f_new.to_stata('{}\\Data\\Ready\\new_accuracymeasuresv2_{}{}.dta'.format(rootdir, var, horizon),
                   write_index=False)
    time.sleep(2)

    # forecast revisions
    L1frevision_dict = {}
    L2frevision_dict = {}

    count = 0
    for person in set(f_saved.loc[:, 'person']):

        f = f_saved.copy()
        f = f[(f['person'] == person)]
        f = f.reset_index()
        N = len(f.index)


        def createHistogram(survey, ydate,
                            qdate):  # survey will be the index of the observation we want to create a histogram for. Outputs a histogram object

            newcdf = cdf.copy()

            bins = binInfo[(binInfo['ydate'] == ydate) & (binInfo['qdate'] == qdate)]
            bins.reset_index(inplace=True)
            startbin = int(bins.loc[0, 'start_bin_{}'.format(
                var)])  # need to cast as an integer because it returns a floating point number
            endbin = int(bins.loc[0, 'end_bin_{}'.format(var)])

            newcdf.loc[:startbin,
            'probs'] = 0  # includes startbin just in case startbin==1, so we don't index by startbin-1 = 0, which is out of range
            newcdf.loc[startbin:endbin, 'probs'] = f.loc[survey, 'c1':'c{}'.format(endbin - startbin + 1)].values

            return Histogram(newcdf, startbin, endbin)


        indices = []  # to be filled up with all indices k such that "person" responded in survey k and survey k+1 (the subsequent quarter)
        for k in range(1, N):
            lag = f.loc[k - 1, 'ydate':'qdate']
            now = f.loc[k, 'ydate':'qdate']
            if now['ydate'] == lag['ydate'] and now['qdate'] == lag['qdate'] + 1:
                indices.append(k - 1)  # because we want to compare k to k+1
            elif now['ydate'] == lag['ydate'] + 1 and now['qdate'] == 1 and lag['qdate'] == 4:
                indices.append(k - 1)

        L1 = pd.Series(name='wass_frev', index=f.index)  # to be filled up with forecast revision measures
        L2 = pd.Series(name='mall_frev', index=f.index)

        for i in indices:  # gets distances between histograms for survey i and i+1
            L1[i], L2[i] = getDistances(createHistogram(i, f.loc[i, 'ydate'], f.loc[i, 'qdate']),
                                        createHistogram(i + 1, f.loc[i + 1, 'ydate'], f.loc[i + 1, 'qdate']))

        L1 = pd.concat([L1, f['index']], axis=1)
        L2 = pd.concat([L2, f['index']], axis=1)

        L1.index = L1['index']
        L2.index = L2['index']

        L1 = L1['wass_frev']
        L2 = L2['mall_frev']

        print(person, len(indices))

        L1frevision_dict[count] = L1
        L2frevision_dict[count] = L2

        count += 1

    L1frev = pd.concat([L1frevision_dict[k] for k in range(0, count)])
    L2frev = pd.concat([L2frevision_dict[k] for k in range(0, count)])
    bothsorted = pd.concat([L1frev, L2frev], axis=1).sort_index()

    bothsorted.index = f_new.index

    # dataset is the final product for this horizon/var
    dataset = pd.concat([f_new, bothsorted], axis=1)

    dataset.to_stata("{}/Data/Ready/accuracymeasures_with_revisions_{}{}.dta".format(rootdir, var, horizon),
                     write_index=False)





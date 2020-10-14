using Toybox.Test;

(:test)
function minmaxavgTestLast(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("last = " + stats.last());
	return (stats.last() == 3); 
}

(:test)
function minmaxavgTestMin(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("min = " + stats.min());
	return (stats.min() == 1); 
}

(:test)
function minmaxavgTestMax(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("max = " + stats.max());
	return (stats.max() == 3); 
}

(:test)
function minmaxavgTestAvg(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("avg = " + stats.avg());
	return (stats.avg() == 2); 
}

(:test)
function minmaxavgTestCount(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("count = " + stats.count());
	return (stats.count() == 3); 
}

(:test)
function minmaxavgTestTotal(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("total = " + stats.total());
	return (stats.total() == 6); 
}

(:test)
function minmaxavgTestAvgWithZeros(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(0);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("avg = " + stats.avg());
	return (stats.avg() == 1.5); 
}

(:test)
function minmaxavgTestAvgWithoutZeros(logger) {
	
	var stats = new MinMaxAvg(false);
	stats.setData(0);
	stats.setData(1);
	stats.setData(2);
	stats.setData(3);

	logger.debug("avg = " + stats.avg());
	return (stats.avg() == 2); 
}

(:test)
function minmaxavgTestMinWithNegativeValues(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(-1);
	stats.setData(-2);
	stats.setData(-3);

	logger.debug("min = " + stats.min());
	return (stats.min() == -3); 
}

(:test)
function minmaxavgTestMaxWithNegativeValues(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(-1);
	stats.setData(-2);
	stats.setData(-3);

	logger.debug("max = " + stats.max());
	return (stats.max() == -1); 
}

(:test)
function minmaxavgTestAvgWithNegativeValues(logger) {
	
	var stats = new MinMaxAvg(true);
	stats.setData(-1);
	stats.setData(-2);
	stats.setData(-3);

	logger.debug("avg = " + stats.avg());
	return (stats.avg() == -2); 
}

var util = require('util');

var TapReporter = function (baseReporterDecorator) {
    var self = this;

    baseReporterDecorator(self);

    self.BROWSER_COMMENT = '# [Browser]: %s\n';
    self.BROWSER_TOTAL = '1..%s\n';
    self.BROWSER_PASSED = 'ok %s - [Browser]: %s\n';
    self.BROWSER_FAILED = 'not ok %s - [Browser]: %s\n';
    self.BROWSER_SKIPPED = 'ok %s # SKIP [Browser]: %s\n';
    self.BROWSER_TOTAL_FILE = '    1..%s\n';
    self.FILE_COMMENT = '    # [Test suite]: %s\n';
    self.FILE_PASSED = '    ok %s - [Test suite]: %s\n';
    self.FILE_FAILED = '    not ok %s - [Test suite]: %s\n';
    self.FILE_SKIPPED = '    ok %s # SKIP [Test suite]: %s\n';
    self.FILE_TOTAL_TESTED = '        1..%s\n';
    self.FILE_TOTAL_SKIPPED = '        1..0 # SKIP %s\n';
    self.TEST_SUITE_BEGIN = '        # [Begin test suite]: %s\n';
    self.TEST_SUITE_END = '        # [End test suite]: %s\n';
    self.TEST_PASSED = '        ok %s - %s\n';
    self.TEST_FAILED = '        not ok %s - %s\n';
    self.TEST_SKIPPED = '        ok %s # SKIP %s\n';

    self.initBrowser = function (browser) {
        self.browsers[browser.id] = {
            name: browser.name,
            log: [],
            currentFile: null,
            currentTestSuites: null,
            currentTestSuiteDeep: 1,
            hasFailedFile: false,
            hasFailedTest: false,
            totalFileCount: 0,
            totalTestCount: 0,
            skippedTestCount: 0
        };
    };

    self.onRunStart = function (browsers) {
        self.browsers = {};
        browsers.forEach(self.initBrowser);
    };

    self.onBrowserStart = function (browser) {
        self.initBrowser(browser);
    };

    self.specSuccess = function (browser, result) {
        self.logTestResult(browser.id, result, self.TEST_PASSED);
    };

    self.specFailure = function (browser, result) {
        self.logTestResult(browser.id, result, self.TEST_FAILED);
    };

    self.specSkipped = function (browser, result) {
        self.logTestResult(browser.id, result, self.TEST_SKIPPED);
    };

    self.onRunComplete = function () {
        self.writeLog();
    };

    self.writeLog = function () {
        var browserCount = 0;
        var browserIds = Object.keys(self.browsers);
        browserIds.forEach(function (browserId) {
            browserCount++;
            var browser = self.browsers[browserId];
            self.logFileResult(browser);
            if (browser.totalFileCount > 0) {
                self.write(util.format(self.BROWSER_COMMENT, browser.name));
                self.write(browser.log.join(''));
                self.write(util.format(self.BROWSER_TOTAL_FILE, browser.totalFileCount));
                if (!browser.hasFailedFile) {
                    self.write(util.format(self.BROWSER_PASSED, browserCount, browser.name));
                }
                else {
                    self.write(util.format(self.BROWSER_FAILED, browserCount, browser.name));
                }
            }
            else {
                self.write(util.format(self.BROWSER_SKIPPED, browserCount, browser.name));
            }
        });
        self.write(util.format(self.BROWSER_TOTAL, browserIds.length));
    };

    self.logFileResult = function (browser) {
        if (browser.totalTestCount != browser.skippedTestCount) {
            self.logTestSuiteComment(browser, null, true);
            browser.log.push(util.format(self.FILE_TOTAL_TESTED, browser.totalTestCount));
            if (!browser.hasFailedTest) {
                browser.log.push(util.format(self.FILE_PASSED, ++browser.totalFileCount, browser.currentFile));
            }
            else {
                browser.hasFailedFile = true;
                browser.log.push(util.format(self.FILE_FAILED, ++browser.totalFileCount, browser.currentFile));
            }
        }
        else {
            browser.log = browser.log.slice(0, browser.log.length - browser.skippedTestCount);
            browser.log.push(util.format(self.FILE_TOTAL_SKIPPED, browser.currentFile));
            browser.log.push(util.format(self.FILE_SKIPPED, ++browser.totalFileCount, browser.currentFile));
        }
        browser.totalTestCount = browser.skippedTestCount = 0;
        browser.hasFailedTest = false;
    };

    self.logFileComment = function (browser, file) {
        var isFirstFile = !browser.currentFile;
        var isNewFile = browser.currentFile !== file;
        if (isNewFile || isFirstFile) {
            browser.currentFile = file;
            if (!isFirstFile) {
                self.logFileResult(browser);
            }
            browser.log.push(util.format(self.FILE_COMMENT, browser.currentFile));
        }
    };

    self.logTestSuiteComment = function (browser, suites, last) {
        if (!last) {
            var testSuiteDeep = suites.length;
            if (testSuiteDeep > browser.currentTestSuiteDeep) {
                browser.currentTestSuiteDeep++;
                browser.currentTestSuites = suites.slice(1, suites.length).join(' -> ');
                browser.log.push(util.format(self.TEST_SUITE_BEGIN, browser.currentTestSuites));
            } else if (testSuiteDeep < browser.currentTestSuiteDeep) {
                browser.currentTestSuiteDeep--;
                browser.log.push(util.format(self.TEST_SUITE_END, browser.currentTestSuites));
            }
        }
        else {
            if (browser.currentTestSuiteDeep > 1) {
                browser.currentTestSuiteDeep = 1;
                browser.log.push(util.format(self.TEST_SUITE_END, browser.currentTestSuites));
            }
        }
    };

    self.logTestResult = function (browserId, result, message) {
        var browser = self.browsers[browserId];
        self.logFileComment(browser, result.suite[0]);
        self.logTestSuiteComment(browser, result.suite, false);
        browser.log.push(util.format(message, ++browser.totalTestCount, result.description));
        if (message == self.TEST_FAILED) {
            browser.hasFailedTest = true;
        }
        else if (message == self.TEST_SKIPPED) {
            browser.skippedTestCount++;
        }
    };
};

TapReporter.$inject = ['baseReporterDecorator'];

module.exports = {
    'reporter:tap': ['type', TapReporter]
};

describe("1st level at 07.karma.t.test.js", function () {
    iit("should be passed 1", function () {
        expect(true).toBe(true);
    });

//    iit("should be failed 1", function () {
//        expect(true).toBe(false);
//    });

    it("should be skipped 1", function () {
    });

    describe("2nd level", function () {
        iit("should be passed 2", function () {
            expect(true).toBe(true);
        });

//        iit("should be failed 2", function () {
//            expect(true).toBe(false);
//        });

        it("should be skipped 2", function () {
        });

        describe("3rd level", function () {
            iit("should be passed 3", function () {
                expect(true).toBe(true);
            });

//            iit("should be failed 3", function () {
//                expect(true).toBe(false);
//            });

            it("should be skipped 3", function () {
            });
        });
    });
});
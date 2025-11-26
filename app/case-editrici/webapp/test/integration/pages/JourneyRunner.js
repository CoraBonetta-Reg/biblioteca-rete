sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"biblioteca/rete/caseeditrici/test/integration/pages/CaseEditriciList",
	"biblioteca/rete/caseeditrici/test/integration/pages/CaseEditriciObjectPage"
], function (JourneyRunner, CaseEditriciList, CaseEditriciObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('biblioteca/rete/caseeditrici') + '/test/flpSandbox.html#bibliotecaretecaseeditrici-tile',
        pages: {
			onTheCaseEditriciList: CaseEditriciList,
			onTheCaseEditriciObjectPage: CaseEditriciObjectPage
        },
        async: true
    });

    return runner;
});


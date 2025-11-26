sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"biblioteca/rete/copie/test/integration/pages/CopieList",
	"biblioteca/rete/copie/test/integration/pages/CopieObjectPage"
], function (JourneyRunner, CopieList, CopieObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('biblioteca/rete/copie') + '/test/flpSandbox.html#bibliotecaretecopie-tile',
        pages: {
			onTheCopieList: CopieList,
			onTheCopieObjectPage: CopieObjectPage
        },
        async: true
    });

    return runner;
});


sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"biblioteca/rete/titoli/test/integration/pages/TitoliList",
	"biblioteca/rete/titoli/test/integration/pages/TitoliObjectPage"
], function (JourneyRunner, TitoliList, TitoliObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('biblioteca/rete/titoli') + '/test/flpSandbox.html#bibliotecaretetitoli-tile',
        pages: {
			onTheTitoliList: TitoliList,
			onTheTitoliObjectPage: TitoliObjectPage
        },
        async: true
    });

    return runner;
});


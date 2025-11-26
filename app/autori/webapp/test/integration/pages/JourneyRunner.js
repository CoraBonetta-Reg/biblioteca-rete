sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"biblioteca/rete/autori/test/integration/pages/AutoriList",
	"biblioteca/rete/autori/test/integration/pages/AutoriObjectPage"
], function (JourneyRunner, AutoriList, AutoriObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('biblioteca/rete/autori') + '/test/flpSandbox.html#bibliotecareteautori-tile',
        pages: {
			onTheAutoriList: AutoriList,
			onTheAutoriObjectPage: AutoriObjectPage
        },
        async: true
    });

    return runner;
});


sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"biblioteca/rete/biblioteche/test/integration/pages/BibliotecheList",
	"biblioteca/rete/biblioteche/test/integration/pages/BibliotecheObjectPage"
], function (JourneyRunner, BibliotecheList, BibliotecheObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('biblioteca/rete/biblioteche') + '/test/flpSandbox.html#bibliotecaretebiblioteche-tile',
        pages: {
			onTheBibliotecheList: BibliotecheList,
			onTheBibliotecheObjectPage: BibliotecheObjectPage
        },
        async: true
    });

    return runner;
});


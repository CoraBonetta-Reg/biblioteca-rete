sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"biblioteca/rete/categorie/test/integration/pages/CategorieList",
	"biblioteca/rete/categorie/test/integration/pages/CategorieObjectPage"
], function (JourneyRunner, CategorieList, CategorieObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('biblioteca/rete/categorie') + '/test/flpSandbox.html#bibliotecaretecategorie-tile',
        pages: {
			onTheCategorieList: CategorieList,
			onTheCategorieObjectPage: CategorieObjectPage
        },
        async: true
    });

    return runner;
});


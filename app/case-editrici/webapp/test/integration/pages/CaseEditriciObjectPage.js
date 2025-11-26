sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'biblioteca.rete.caseeditrici',
            componentId: 'CaseEditriciObjectPage',
            contextPath: '/CaseEditrici'
        },
        CustomPageDefinitions
    );
});
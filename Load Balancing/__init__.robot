*** Settings ***
Documentation    Load Balancing method tests
Resource        ../common.resource
Variables       settings.yaml
Library         ../F5Rest.py    ${f5_primary}     ${user}
Suite Setup     Setup Test
Suite Teardown  Teardown

*** Keywords ***
Setup Test
    [Documentation]     Configure lab for load balancing tests.
    Configure F5

Configure F5
    [Documentation]     Setup a basic http virtual server to use in 
    ...                 load balancing test cases.
    [tags]  Setup
    Log variables
    tmsh create ltm node ${node_1} address ${node_1}
    tmsh create ltm node ${node_2} address ${node_2}
    tmsh create ltm pool ${pool} { members add { ${node_1}:80 ${node_2}:80 } monitor none }
    tmsh create ltm virtual ${virtual_server} destination ${virtual_server}:80 mask 255.255.255.255 ip-protocol tcp pool ${pool}
    tmsh create ltm virtual ${virtual_server}-https destination ${virtual_server}:443 mask 255.255.255.255 ip-protocol tcp pool ${pool}
    tmsh modify ltm virtual-address ${virtual_server} route-advertisement selective

Teardown
    [Documentation]     Teardown the configuration for this test suite.
    [tags]  Teardown
    tmsh delete ltm virtual ${virtual_server}
    tmsh delete ltm pool ${pool}
    tmsh delete ltm node ${node_1}
    tmsh delete ltm node ${node_2}
    stop ixload test
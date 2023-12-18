package cases.util;

class ExportData {
    public static var Persons:String = '{
        "tables": [
            {
                "name": "Icon",
                "columns": [
                    {
                        "name": "iconId",
                        "type": "Number",
                        "options": []
                    },
                    {
                        "name": "path",
                        "type": "Text(50)",
                        "options": []
                    }
                ],
                "data": [
                    [
                        1,
                        "/somepath/icon1.png"
                    ],
                    [
                        2,
                        "/somepath/icon2.png"
                    ],
                    [
                        3,
                        "/somepath/icon3.png"
                    ]
                ]
            },
            {
                "name": "Organization",
                "columns": [
                    {
                        "name": "organizationId",
                        "type": "Number",
                        "options": []
                    },
                    {
                        "name": "name",
                        "type": "Text(50)",
                        "options": []
                    },
                    {
                        "name": "iconId",
                        "type": "Number",
                        "options": []
                    }
                ],
                "data": [
                    [
                        1,
                        "ACME Inc",
                        2
                    ],
                    [
                        2,
                        "Haxe LLC",
                        1
                    ],
                    [
                        3,
                        "PASX Ltd",
                        3
                    ]
                ]
            },
            {
                "name": "Person",
                "columns": [
                    {
                        "name": "personId",
                        "type": "Number",
                        "options": [
                            "PrimaryKey",
                            "AutoIncrement"
                        ]
                    },
                    {
                        "name": "lastName",
                        "type": "Text(50)",
                        "options": []
                    },
                    {
                        "name": "firstName",
                        "type": "Text(50)",
                        "options": []
                    },
                    {
                        "name": "iconId",
                        "type": "Number",
                        "options": []
                    },
                    {
                        "name": "contractDocument",
                        "type": "Binary",
                        "options": []
                    },
                    {
                        "name": "hourlyRate",
                        "type": "Decimal",
                        "options": []
                    }
                ],
                "data": [
                    [
                        1,
                        "Harrigan",
                        "Ian",
                        1,
                        "dGhpcyBpcyBpYW5zIGNvbnRyYWN0IGRvY3VtZW50",
                        111.222
                    ],
                    [
                        2,
                        "Barker",
                        "Bob",
                        3,
                        null,
                        333.444
                    ],
                    [
                        3,
                        "Mallot",
                        "Tim",
                        2,
                        null,
                        555.666
                    ],
                    [
                        4,
                        "Parker",
                        "Jim",
                        1,
                        null,
                        777.888
                    ]
                ]
            },
            {
                "name": "Person_Organization",
                "columns": [
                    {
                        "name": "Person_personId",
                        "type": "Number",
                        "options": []
                    },
                    {
                        "name": "Organization_organizationId",
                        "type": "Number",
                        "options": []
                    }
                ],
                "data": [
                    [
                        1,
                        1
                    ],
                    [
                        2,
                        1
                    ],
                    [
                        3,
                        1
                    ],
                    [
                        2,
                        2
                    ],
                    [
                        4,
                        2
                    ],
                    [
                        1,
                        3
                    ],
                    [
                        4,
                        3
                    ]
                ]
            }
        ]
    }';
}
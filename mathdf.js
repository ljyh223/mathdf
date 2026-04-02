async function Wb(a) {
    if ('' == a) return !1;
    e.Nh3.classList.add('hide');
    Hb = [];
    var b = qd(),
        g = (Q, R = '') => `<div class='ktx${R}'>\\[${Q}\\]</div>`,
        l = 0,
        n = 0,
        u = document.getElementById('show-linear-int').checked,
        r = !1;
    document.createElement('div');
    var f = '',
        v = 0,
        C = [],
        p = document.createElement('div');
    a = new td(p);
    var J = [],
        w = [],
        E = [],
        P = 'defint' === b[0][0] ? !0 : !1,
        F = 'x';
    hb = '';
    na ||
        (
            e.Jnx.replaceChildren ? e.Jnx.replaceChildren() : e.Jnx.textContent = ''
        );
    e.aQF.textContent = '';
    if (P) {
        var m = b[b.length - 1],
            N = '',
            B = '';
        13 == m[1][0] &&
            (N = m[1][1], b.pop(), m = b[b.length - 1]);
        30 == m[1][0] &&
            (B = m[1][1], '' != B && (B = '\\approx ' + B), b.pop(), m = b[b.length - 1]);
        for (var A = '', T = '', V = '', H = 3; 1 < H && 2 != b.length; H--) {
            var d = b[b.length - H];
            if (- 4 == d[0]) switch (d[1][0]) {
                case 6:
                    V = d[1][1];
                    A += a.getHTML({
                        path: [
                            'defs',
                            6
                        ],
                        'ex-params': {
                            '::x': d[2],
                            '::q': d[1][2]
                        }
                    });
                    T = d[1][3];
                    break;
                case 14:
                    '' === V &&
                        (V = d[1][1]),
                        A += a.getHTML({
                            path: [
                                'defs',
                                14
                            ],
                            'ex-params': {
                                '::r': d[1][4],
                                '::q': d[1][2]
                            }
                        }),
                        T = d[1][3]
            }
        }
        H = '';
        4 != m[1][0] &&
            7 != m[1][0] ||
            '' === m[1][6] ||
            (
                d = [],
                d = m[1][6].slice(0, - 1).split(/&/g),
                d = d.map(function (Q) {
                    return '<div class=\'ktx\'>\\[' + Q + '\\]</div>'
                }),
                H = d.join('<div class=\'kbr\'></div>')
            );
        switch (m[1][0]) {
            case 0:
            case 3:
            case 4:
            case 5:
            case 8:
            case 9:
            case 17:
                F = m[2];
                var D = '';
                '' !== N &&
                    (
                        D = a.getHTML({
                            path: [
                                'constraint'
                            ]
                        }) + g(N) + '<div class=\'kbr\'></div>'
                    );
                f = a.getHTML({
                    path: [
                        'initintdef'
                    ],
                    'ex-params': {
                        '::x': m[1][1],
                        '::q': D,
                        '::p': B
                    }
                });
                break;
            case 1:
            case 2:
                F = m[2];
                D = '';
                '' !== N &&
                    (
                        D = a.getHTML({
                            path: [
                                'constraint'
                            ]
                        }) + g(N) + '<div class=\'kbr\'></div>'
                    );
                a.addStep({
                    path: [
                        'initintdefund'
                    ],
                    'ex-params': {
                        '::x': m[1][1],
                        '::q': D
                    }
                });
                break;
            case 12:
            case 16:
                F = m[2];
                var x = m[1][1];
                12 == m[1][0] &&
                    (x = m[1][2]);
                D = '';
                '' !== N &&
                    (
                        D = a.getHTML({
                            path: [
                                'constraint'
                            ]
                        }) + g(N) + '<div class=\'kbr\'></div>'
                    );
                a.addStep({
                    path: [
                        'initintdefnocalc'
                    ],
                    'ex-params': {
                        '::x': x,
                        '::q': D
                    }
                });
                break;
            case 7:
            case 10:
            case 11:
                F = m[2];
                D = '';
                '' !== N &&
                    (
                        D = a.getHTML({
                            path: [
                                'constraint'
                            ]
                        }) + g(N) + '<div class=\'kbr\'></div>'
                    );
                f = a.getHTML({
                    path: [
                        'initintdefund'
                    ],
                    'ex-params': {
                        '::x': m[1][1],
                        '::q': D
                    }
                });
                break;
            case 18:
                F = m[2],
                    a.addStep({
                        path: [
                            'initintdefcomplex'
                        ],
                        'ex-params': {
                            '::x': m[1][1]
                        }
                    })
        }
        switch (m[1][0]) {
            case 0:
                F = m[3];
                x = m[4];
                f = f.replace(/::a/g, x);
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                D = ('' !== T ? T + '\\cdot' : '') + '\\htmlClass{brown}{F\\left(' + m[3] + '\\right)}{\\large|}^{' + m[1][3] + '}_{' + m[1][2] + '}=' + ('' !== T ? T + '\\,\\left(' : '') + '\\htmlClass{antider-b}{F\\left(' + m[1][3] + '\\right)}-\\htmlClass{antider-a}{F\\left(' + m[1][2] + '\\right)}' + ('' !== T ? '\\right)' : '');
                a.addStep({
                    path: [
                        'newton0'
                    ],
                    'ex-params': {
                        '::x': m[3],
                        '::q': g(D, ' kee')
                    }
                });
                f = {};
                f['::x'] = m[3];
                f['::p'] = m[2];
                f['::b'] = m[1][3];
                f['::w'] = m[1][5];
                f['::a'] = m[1][2];
                f['::r'] = m[1][4];
                f['::q'] = x;
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': f
                });
                break;
            case 3:
                x = m[3];
                f = f.replace(/::a/g, x);
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                x = m[1][1] + '=' + m[3];
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::q': x
                    }
                });
                break;
            case 4:
                x = m[3];
                f = f.replace(/::a/g, x);
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                x = ('' === T ? '' : T +
                    '\\,\\left(') + m[1][2] + ('' === T ? '' : '\\right)');
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::x': m[2],
                        '::q': x
                    }
                });
                D = '' === H ? '' : '<div class=\'khline\'></div>' + a.getHTML({
                    path: [
                        'def',
                        11
                    ]
                }) + g('F\\left(' + m[2] + '\\right)=' + m[1][5]) + '<div class=\'kbr\'></div>' + a.getHTML({
                    path: [
                        'def',
                        10
                    ]
                }) + H;
                f = {};
                f['::x'] = m[2];
                f['::y'] = m[1][3];
                f['::a'] = m[1][4];
                f['::q'] = g(m[3], ' kee');
                f['::p'] = D;
                a.addStep({
                    path: [
                        'newton'
                    ],
                    'ex-params': f
                });
                break;
            case 5:
                f = f.replace(/::a/g, '0');
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::x': F,
                        '::q': '0'
                    }
                });
                break;
            case 7:
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                x = ('' === T ? '' : T + '\\,\\left(') + m[1][2] + ('' === T ? '' : '\\right)');
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::x': m[2],
                        '::q': x
                    }
                });
                D = '' === H ? '' : '<div class=\'khline\'></div>' +
                    g('F\\left(' + m[2] + '\\right)=' + m[1][5]) + '<div class=\'kbr\'></div>' + a.getHTML({
                        path: [
                            'def',
                            10
                        ]
                    }) + H;
                f = {};
                f['::x'] = m[2];
                f['::y'] = m[1][3];
                f['::a'] = m[1][4];
                f['::q'] = '<div class=\'kbr\'></div><div class=\'kbr\'></div>' + a.getHTML({
                    path: [
                        'def',
                        4
                    ]
                });
                f['::p'] = D;
                a.addStep({
                    path: [
                        'newton'
                    ],
                    'ex-params': f
                });
                break;
            case 8:
                x = m[3];
                f = f.replace(/::a/g, x);
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                x = m[1][2] + '=' + m[1][5] +
                    '{\\htmlClass{brown}{F\\left(' + m[2] + '\\right)}}{\\large|}^{' + m[1][4] + '}_{' + m[1][3] + '}';
                a.addStep({
                    path: [
                        'improper1'
                    ],
                    'ex-params': {
                        '::q': x
                    }
                });
                a.addStep({
                    path: [
                        'newton0'
                    ],
                    'ex-params': {
                        '::x': m[2],
                        '::q': ''
                    }
                });
                f = {};
                f['::x'] = m[2];
                f['::p'] = m[1][6];
                f['::b'] = m[1][7];
                f['::a'] = m[1][8];
                f['::q'] = m[3];
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': f
                });
                break;
            case 9:
                f = f.replace(/::a/g, '0');
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::q': '0'
                    }
                });
                break;
            case 10:
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                x = m[1][2] + '=' + m[1][5] + '{\\htmlClass{brown}{F\\left(' + m[2] + '\\right)}}{\\large|}^{b}_{' + m[1][3] + '}';
                a.addStep({
                    path: [
                        'improper1'
                    ],
                    'ex-params': {
                        '::q': x
                    }
                });
                a.addStep({
                    path: [
                        'newton0'
                    ],
                    'ex-params': {
                        '::x': m[2],
                        '::q': ''
                    }
                });
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::x': m[2],
                        '::p': m[1][6],
                        '::b': m[1][7],
                        '::a': m[1][8]
                    }
                });
                break;
            case 11:
                a.addRawStep(f);
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::x': m[1][2]
                    }
                });
                break;
            case 15:
                x = m[3];
                f = f.replace(/::a/g, x);
                '' != f ? a.addRawStep(f) : (
                    F = m[2],
                    D = '',
                    '' !== N &&
                    (
                        D = a.getHTML({
                            path: [
                                'constraint'
                            ]
                        }) + g(N) + '<div class=\'kbr\'></div>'
                    ),
                    a.addStep({
                        path: [
                            'initintdef'
                        ],
                        'ex-params': {
                            '::a': x,
                            '::x': m[1][1],
                            '::q': D,
                            '::p': B
                        }
                    })
                );
                a.addStep({
                    path: [
                        'stepsolutioncalc'
                    ]
                });
                a.addStep({
                    path: [
                        'calcindex'
                    ],
                    'ex-params': {
                        '::q': '' != V ? V : m[1][1],
                        '::p': ''
                    }
                });
                '' != A &&
                    a.addRawStep(A);
                a.addStep({
                    path: [
                        'defs',
                        m[1][0]
                    ],
                    'ex-params': {
                        '::r': m[1][3],
                        '::q': m[1][2]
                    }
                });
                a.addStep({
                    path: [
                        'newton0'
                    ],
                    'ex-params': {
                        '::x': m[2],
                        '::q': g(x, ' kee')
                    },
                    regexps: [
                        ['cr-gn',
                            'cr-g']
                    ]
                });
                break;
            case 17:
                x = m[3],
                    f = f.replace(/::a/g, x),
                    a.addRawStep(f),
                    a.addStep({
                        path: [
                            'stepsolutioncalc'
                        ]
                    }),
                    a.addStep({
                        path: [
                            'calcindex'
                        ],
                        'ex-params': {
                            '::q': '' !=
                                V ? V : m[1][1],
                            '::p': ''
                        }
                    }),
                    '' != A &&
                    a.addRawStep(A),
                    x = m[1][1] + '=' + m[3],
                    a.addStep({
                        path: [
                            'defs',
                            m[1][0]
                        ],
                        'ex-params': {
                            '::q': x
                        }
                    })
        }
        b = b.slice(1, - 1);
        '' !== A &&
            b.pop()
    }
    for (H = 0; H < b.length; H++) switch (d = b[H], d[0]) {
        case - 2:
            hb = (d[3] + ('' != d[3] ? '+' : '') + 'C').replace(/'/g, '');
            2 < ya.length &&
                (ya[2] = d[3]);
            a.addStep({
                path: [
                    'export'
                ]
            });
            A = 'initint';
            f = {};
            m = [
                [/::n/g,
                    '']
            ];
            P &&
                (A = 'antider', f['::p'] = F);
            x = d.map(Q => Q);
            x[2] = '' !== x[2] ? x[2] + '+C' : 'C';
            D = '';
            '' === d[4] ||
                P ||
                (
                    D = a.getHTML({
                        path: [
                            'constraint'
                        ]
                    }) + g(d[4]) + '<div class=\'kbr\'></div>'
                );
            f['::q'] = D;
            a.addStep({
                path: [
                    A
                ],
                params: x.slice(1),
                'ex-params': f,
                regexps: m
            });
            a.addStep({
                path: [
                    'stepsolutioncalc'
                ]
            });
            break;
        case - 10:
            w = d.slice(1);
            break;
        case - 1:
            var oa = '0' == d[2] ? '' : '\\;\\htmlId{branch-from-' + d[2] + '}{\\htmlClass{red}{\\left(' + d[2] + '\\right)}}';
            x = d[1].join('');
            a.addStep({
                path: [
                    'calcindex'
                ],
                params: d[1].slice(1),
                'ex-params': {
                    '::q': x,
                    '::p': oa
                }
            });
            break;
        case 0:
            D = [
                'table',
                d[1][0]
            ];
            f = {};
            5 == d[1][0] ? D = [
                'table',
                7,
                d[1][2]
            ] : 4 == d[1][0] ? D = [
                'table',
                d[1][0],
                d[1][1]
            ] : 7 == d[1][0] ? D = [
                'todif'
            ] : Array.isArray(a.getHTML({
                path: [
                    'table',
                    d[1][0]
                ],
                test: !0
            })) &&
            (D = [
                'table',
                d[1][0],
                0
            ]);
            x = d[3];
            x = '1' == d[2] ? '\\htmlClass{gray}{' + d[3] + '}' : d[2] + '\\cdot\\htmlClass{gray}{' + d[3] + '}';
            '' != d[4] &&
                (x += '=' + d[4]);
            H < b.length - 1 &&
                11 == b[H + 1][0] &&
                (f['cr-g'] = 'cr-gg', f.kee = 'keq');
            f['::q'] = x;
            a.addStep({
                path: D,
                params: d[1].slice(1),
                'ex-params': f
            });
            break;
        case 2:
            A = 'linear';
            f = {};
            x = d[3];
            B = N = '';
            switch (d[1][0]) {
                case 1:
                    A = 'group',
                        D = '',
                        D = '1' == d[1][2] ? '{' + d[1][1] + '= \\left(' + d[1][3] + '\\right)' + d[1][4] + d[1][5] + '}' : '{' + d[1][1] + '=\\htmlClass{blue}{' + d[1][2] + '}\\,\\left(' +
                            d[1][3] + '\\right)' + d[1][4] + d[1][5] + '}',
                        f['::p'] = D
            }
            H < b.length - 1 &&
                11 == b[H + 1][0] &&
                (f['cr-ln'] = 'cr-ll');
            D = '';
            for (x = 0; x < d[4][1].length; x++) D += d[4][1][x][0] + (
                '-' != d[4][1][x][0] &&
                    '+' != d[4][1][x][0] &&
                    '' != d[4][1][x][0] ? '\\cdot' : ''
            ) + '\\htmlId{branch-' + d[4][1][x][1] + '}{\\htmlClass{red}{\\left(' + d[4][1][x][1] + '\\right)}}',
                n++;
            '1' == d[2] ? (x = d[3], N = D) : '-1' == d[2] ? (x = '-\\left(' + d[3] + '\\right)', N = '-\\left(' + D + '\\right)') : (
                x = d[2] + '\\left(' + d[3] + '\\right)',
                N = d[2] + '\\left(' + D + '\\right)'
            );
            B = d[4][2];
            f['::q'] = x + '=';
            f['::w'] = '=' + N;
            f['::r'] = '=' + B;
            a.addStep({
                path: [
                    A
                ],
                params: d[1].slice(1),
                'ex-params': f
            });
            break;
        case 3:
            u ||
                (
                    x = d[3],
                    x = '1' == d[1] ? '-1' == d[2] ? '\\htmlClass{blue}{-}' + d[3] : '\\htmlClass{blue}{' + d[2] + '}' + d[3] : d[1] + '\\cdot\\htmlClass{blue}{' + d[2] + '}' + d[3],
                    a.addStep({
                        path: [
                            'linear3'
                        ],
                        'ex-params': {
                            '::q': x,
                            '::p': oa
                        }
                    })
                );
            break;
        case 4:
            x = d[3];
            x = '1' == d[2] ? d[3] : '-1' == d[2] ? '-' + d[3] : d[2] + d[3];
            A = d[4] + '^{0}:';
            for (D = 1; D < d[1][3].length; D++) A = A + '\\\\' + d[4] + '^{' + D + '}:';
            a.addStep({
                path: [
                    'undef4'
                ],
                params: d[1],
                'ex-params': {
                    '::p': A,
                    '::q': x,
                    '::w': d[1][3].join('\\\\'),
                    '::r': d[1][4].join('\\\\'),
                    '::k': d[4]
                }
            });
            break;
        case 5:
            l = + d[5];
            f = '';
            switch (d[1][0]) {
                case 4:
                    f = a.getHTML({
                        path: [
                            'varchange54'
                        ],
                        params: d[1][1]
                    });
                    '1' == d[1][1][5] &&
                        (f += a.getHTML({
                            path: [
                                'varchange541'
                            ],
                            params: d[1][1]
                        }));
                    '2' == d[1][1][5] &&
                        (f += a.getHTML({
                            path: [
                                'varchange542'
                            ],
                            params: d[1][1]
                        }));
                    '3' == d[1][1][5] &&
                        (f += a.getHTML({
                            path: [
                                'varchange543'
                            ],
                            params: d[1][1]
                        }));
                    break;
                case 5:
                    m = [];
                    D = (1 == d[1][1].length ? d[1][1] : '\\left(' + d[1][1] + '\\right)') + '^{\\mathbf{p}}';
                    m.push([/::t/g,
                        '\\sqrt[\\mathrm{n}]{::x}']);
                    m.push([/::x/g,
                        d[1][1]]);
                    f += a.getHTML({
                        path: [
                            'change5'
                        ],
                        'ex-params': {
                            '::p': D,
                            '::w': d[1][2].slice(0, - 1).join(',\\;\\,'),
                            '::r': d[1][2][d[1][2].length - 1]
                        },
                        regexps: m
                    });
                    break;
                case 7:
                    f = g(
                        '\\int{' + d[1][3] + '}\\;{\\mathrm{d}\\left(\\htmlClass{green}{' + d[1][4] + '}\\right)}'
                    ) + g('', ' khline');
                    break;
                case 9:
                    f = g(
                        '\\int{' + d[1][1] + '}\\,\\frac{\\mathrm{d}\\left(\\htmlClass{green}{' + d[1][4] + '}\\right)}{\\sqrt{' + d[1][2] + d[1][3] + '\\,\\left(' + d[1][4] + '\\right)^2}}'
                    ) + g('', ' khline');
                    break;
                case 11:
                    m = [],
                        D = '\\left(' + d[1][2] +
                        '\\right)^{\\mathbf{n}}',
                        m.push([/::t/g,
                            '\\sqrt[n]{\\dfrac{a\\,::x+b}{c\\,::x+d}}']),
                        m.push([/::x/g,
                            d[1][1]]),
                        f = a.getHTML({
                            path: [
                                'change5'
                            ],
                            'ex-params': {
                                '::p': D,
                                '::w': d[1][3].slice(0, - 1).join(',\\,'),
                                '::r': d[1][3][d[1][3].length - 1]
                            },
                            regexps: m
                        })
            }
            D = '' != d[2][1] ||
                '' != d[2][3] ? '' : '\\;';
            x = d[4];
            x = '1' == d[3] ? d[4] : '-1' == d[3] ? '-' + d[4] : d[3] + d[4];
            m = a.getHTML({
                path: [
                    'varchange5'
                ]
            }) + a.getHTML({
                path: [
                    'chgtype',
                    d[1][0]
                ]
            });
            m += f;
            m += '<div class=\'c-row ltr\'>' + g(
                (
                    '' != d[2][1] ||
                        '' != d[2][3] ? '\\def\\arraystretch{2}\\begin{array}{c|c}' :
                        '\\begin{gathered}\\;'
                ) + d[2][0] + (9 != d[1][0] ? '&' + d[2][1] + '\\\\' + D + d[2][2] + '&' + d[2][3] : '') + ('' != d[2][1] || '' != d[2][3] ? '\\end{array}' : '\\end{gathered}'),
                ' chng-style'
            ) + g(
                '\\;\\,\\htmlId{formula-' + d[5] + '}{\\htmlClass{red}{\\left[' + d[5] + '\\right]}}',
                ' no-ovrflw'
            ) + '</div>';
            a.addStep({
                path: [
                    'nchange'
                ],
                'ex-params': {
                    '::p': m,
                    '::q': x
                }
            });
            break;
        case 6:
            x = d[3];
            x = '1' == d[2] ? d[3] : '-1' == d[2] ? '-' + d[3] : d[2] + d[3];
            a.addStep({
                path: [
                    'combo',
                    d[1][0],
                    0
                ],
                params: d[1].slice(1),
                'ex-params': {
                    '::q': x
                }
            });
            break;
        case 7:
            A = 'partint';
            f = {};
            m = [];
            B = N = x = '';
            switch (d[1][0]) {
                case 0:
                    B = d[8][2];
                    break;
                case 1:
                    A = 'partint1m';
                    break;
                case 2:
                    A = 'partint1';
                    break;
                case 3:
                    A = 'partint1m';
                    break;
                case 4:
                    A = 'partint4',
                        x = (1 == d[1][2].length ? '' : '\\left(') + d[1][2] + (1 == d[1][2].length ? '' : '\\right)'),
                        D = d[1].slice(1),
                        f['::x'] = D[0],
                        f['::a'] = D[1],
                        f['::b'] = D[2],
                        f['::n'] = D[3],
                        f['::k'] = D[4],
                        f['::p'] = x,
                        f['::r'] = d[3],
                        f['::w'] = d[4],
                        f['::h'] = d[1][2],
                        x = d[1][5],
                        '1' != d[2] &&
                        (
                            x = '-1' == d[2] ? '-\\left(' + x + '\\right)' : d[2] + '\\left(' + x + '\\right)'
                        ),
                        B = d[2][5]
            }
            H < b.length - 1 &&
                - 1 != [11,
                    12].indexOf(b[H +
                        1][0]) &&
                (m.push(['cr-g',
                    'cr-gn']), m.push(['kee',
                        'keq']));
            D = a.getHTML({
                path: [
                    'parttype',
                    d[1][0]
                ]
            });
            f['::p'] ||
                (f['::p'] = D);
            f['::x'] ||
                (f['::x'] = d[4]);
            f['::a'] ||
                (f['::a'] = d[5]);
            f['::b'] ||
                (f['::b'] = d[6]);
            f['::n'] ||
                (f['::n'] = d[7]);
            switch (d[1][0]) {
                case 0:
                case 1:
                case 2:
                    x = d[3][0] + d[3][1] + (0 != d[1][0] ? '\\htmlClass{green}{' : '') + d[3][2] + (0 != d[1][0] ? '}' : '');
                    '1' == d[2] ? 0 == d[1][0] &&
                        (
                            N = d[8][1][0] + d[8][1][1] + ('+' != d[8][1][1] && '-' != d[8][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[8][1][2] + '}{\\htmlClass{red}{(' + d[8][1][2] +
                            ')}}'
                        ) : '-1' == d[2] ? (
                            x = '-\\left(' + x + '\\right)',
                            0 == d[1][0] &&
                            (
                                N = '-(' + d[8][1][0] + d[8][1][1] + ('+' != d[8][1][1] && '-' != d[8][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[8][1][2] + '}{\\htmlClass{red}{(' + d[8][1][2] + ')}})'
                            )
                        ) : (
                        x = d[2] + '\\left(' + x + '\\right)',
                        0 == d[1][0] &&
                        (
                            N = d[2] + '\\left(' + d[8][1][0] + d[8][1][1] + ('+' != d[8][1][1] && '-' != d[8][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[8][1][2] + '}{\\htmlClass{red}{(' + d[8][1][2] + ')}}\\right)'
                        )
                    );
                    0 == d[1][0] &&
                        n++;
                    0 != d[1][0] ? '-1' !== d[8][2] &&
                        J.push(d[8]) : '-1' !== d[9][2] &&
                    J.push(d[9]);
                    break;
                case 3:
                    x = d[3][0] + '\\;\\cancel{' + d[3][1] + '}\\;\\cancel{' + d[3][2] + '}',
                        '1' != d[2] &&
                        (
                            x = '-1' == d[2] ? '-\\left(' + x + '\\right)' : d[2] + '\\left(' + x + '\\right)'
                        ),
                        x += '=' + d[3][0],
                        J.push(d[8])
            }
            0 == d[1][0] ? (f['::q'] = x + '=', f['::w'] = '=' + N, f['::r'] = '=' + B) : f['::q'] = x;
            var Ta = 'x';
            x.replace(/\\mathrm{d}([^}]+)/, (Q, R) => {
                Ta = R
            });
            f['::j'] = Ta;
            f = a.addStep({
                path: [
                    A
                ],
                'ex-params': f,
                regexps: m
            });
            break;
        case 8:
            f = {};
            x = d[3];
            N = '';
            B = d[4][2];
            '1' == d[2] ? N = d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') +
                '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}' : '-1' == d[2] ? (
                    x = '-\\left(' + d[3] + '\\right)',
                    N = '-\\left(' + d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}\\right)'
                ) : (
                x = d[2] + '\\left(' + d[3] + '\\right)',
                N = d[2] + '\\left(' + d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' +
                d[4][1][2] + '\\right)}}\\right)'
            );
            f['::q'] = x + '=';
            f['::w'] = '=' + N;
            f['::r'] = '=' + B;
            n++;
            f = a.addStep({
                path: [
                    'decreasepow8'
                ],
                params: d[1],
                'ex-params': f
            });
            break;
        case 9:
            x = '';
            x = '1' == d[2] ? d[3] : '-1' == d[2] ? '-' + d[3] : d[2] + d[3];
            a.addStep({
                path: [
                    'trig',
                    d[1][0],
                    0
                ],
                params: d[1].slice(1),
                'ex-params': {
                    '::q': x
                }
            });
            break;
        case 10:
            f = {};
            m = [];
            A = d[5] + '^{0}:';
            for (D = 1; D < d[1][4].length; D++) A = A + '\\\\' + d[5] + '^{' + D + '}:';
            D = a.getHTML({
                path: [
                    'partfrac'
                ]
            });
            '2' == d[1][6] &&
                (D = a.getHTML({
                    path: [
                        'ostro'
                    ]
                }));
            H < b.length - 1 &&
                - 1 != [11,
                    12].indexOf(b[H +
                        1][0]) &&
                (m.push(['cr-g',
                    'cr-gn']), m.push(['kee',
                        'keq']));
            f['::p'] = D;
            f['::r'] = d[6];
            f['::w'] = A;
            f['::e'] = d[1][4].join('\\\\');
            f['::o'] = d[1][5].join('\\\\');
            x = d[3];
            N = '';
            B = d[4][2];
            '1' == d[2] ? N = '+0' != d[4][1][1] ? d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}' : '' : '-1' == d[2] ? (
                x = '-\\left(' + d[3] + '\\right)',
                N = '-\\left(' + d[3] + ('+0' != d[4][1][1] ? '' : '+0') + '\\right)' + (
                    '+0' != d[4][1][1] ? '=-\\left(' +
                        d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}\\right)' : ''
                )
            ) : (
                x = d[2] + '\\left(' + d[3] + '\\right)',
                N = d[2] + '\\left(' + d[3] + ('+0' != d[4][1][1] ? '' : '+0') + '\\right)=' + (
                    '+0' != d[4][1][1] ? d[2] + '\\left(' + d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}\\right)' : ''
                )
            );
            f['::q'] = x +
                '=';
            f['::m'] = '=' + N;
            f['::l'] = '=' + B;
            f['::k'] = d[5];
            n++;
            a.addStep({
                path: [
                    'undef10'
                ],
                params: d[1],
                'ex-params': f,
                regexps: m
            });
            break;
        case 11:
            x = d[2];
            f = {};
            D = '';
            D = '' == d[1][1] ? '\\htmlClass{chng-style}{' + d[1][0] + '}' : '\\htmlClass{chng-style}{\\begin{array}{c|c}' + d[1][0] + '&' + d[1][1] + '\\end{array}}';
            d = '\\;\\,\\htmlId{formula-from-' + d[3] + '}{\\htmlClass{red}{\\left[' + d[3] + '\\right]}}';
            if (H == b.length - 1 || 11 != b[H + 1][0]) f['cr-un'] = 'cr-g',
                f.keq = 'kee';
            f['::q'] = x;
            f['::r'] = D;
            f['::w'] = d;
            a.addStep({
                path: [
                    'undosub'
                ],
                'ex-params': f
            });
            break;
        case 12:
            x = d[2];
            m = [];
            H < b.length - 1 &&
                - 1 != [11,
                    12].indexOf(b[H + 1][0]) &&
                (m.push(['cr-g',
                    'cr-gn']), m.push(['kee',
                        'keq']));
            a.addStep({
                path: [
                    'transform'
                ],
                'ex-params': {
                    '::q': x
                },
                regexps: m
            });
            break;
        case 13:
            A = 'decreasepow131';
            f = {};
            m = [];
            '1' == d[1][2] ? A = 'decreasepow131' : '2' == d[1][2] ? A = 'decreasepow132' : '3' == d[1][2] ? A = 'decreasepow133' : '4' == d[1][2] ? A = 'decreasepow134' : '5' == d[1][2] ? A = 'decreasepow135' : '6' == d[1][2] ? A = 'decreasepow136' : '7' == d[1][2] ? A = 'decreasepow137' : '8' == d[1][2] &&
                (A = 'decreasepow138');
            H < b.length - 1 &&
                - 1 != [11,
                    12].indexOf(b[H + 1][0]) &&
                (m.push(['cr-g',
                    'cr-gn']), m.push(['kee',
                        'keq']));
            x = d[3];
            N = '';
            B = d[4][2];
            '1' == d[2] ? N = d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}' : '-1' == d[2] ? (
                x = '-\\left(' + d[3] + '\\right)',
                N = '-\\left(' + d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}\\right)'
            ) : (
                x = d[2] + '\\left(' + d[3] + '\\right)',
                N = d[2] + '\\left(' + d[4][1][0] + d[4][1][1] + ('-' != d[4][1][1] && '+' != d[4][1][1] && '' != d[4][1][1] ? '\\cdot' : '') + '\\htmlId{branch-' + d[4][1][2] + '}{\\htmlClass{red}{\\left(' + d[4][1][2] + '\\right)}}\\right)'
            );
            f['::q'] = x + '=';
            f['::w'] = '=' + N;
            f['::r'] = '=' + B;
            f['::q'] = x;
            n++;
            a.addStep({
                path: [
                    A
                ],
                params: d[1].slice(0, 2),
                'ex-params': f,
                regexps: m
            });
            break;
        case 32:
            d = JSON.stringify(d);
            d = d.replace(/#/g, '\\');
            d = JSON.parse(d);
            x = d[1].slice(0, - 1);
            D = d[1].slice(- 1)[0];
            m = [];
            f = '';
            if (0 != Ea && Ea[0] == v) for (A = 1; A <= Ea[1]; A++) [x[A - 1],
            x[A]] = [
                    x[A],
                    x[A - 1]
                ];
            for (var Fa in x) {
                for (A = x[Fa]; Array.isArray(A[0]);) A = A[0];
                0 != A.length &&
                    (
                        N = a.getHTML({
                            path: [
                                'method',
                                A[0]
                            ]
                        }),
                        B = x.slice(),
                        T = B.splice(Fa, 1),
                        B.push(T),
                        B.unshift(D),
                        T = d[2].slice(0, - 1),
                        T.push([A[0],
                            B]),
                        N = a.getHTML({
                            path: [
                                'wrapMethod'
                            ],
                            params: A.slice(1),
                            'ex-params': {
                                '::p': E.length,
                                '::q': N
                            }
                        }),
                        f += N,
                        m.push(E.length),
                        E.push(T)
                    )
            }
            a.addRawStep(f);
            C.push(m);
            v++;
            break;
        case - 3:
            x = d[1],
                D = '',
                r = !0,
                a.addStep({
                    path: [
                        'error',
                        d[2]
                    ],
                    'ex-params': {
                        '::q': x,
                        '::p': D
                    }
                })
    }
    if (r && na) e.fhn.classList.add('fast-hidden'),
        e.oHX.classList.add('hidden'),
        e.oHX.classList.remove('part-visible'),
        e.Jb1.classList.add('hidden'),
        e.Jb1.classList.remove('part-visible'),
        e.SHE.classList.add('hidden'),
        e.SHE.classList.remove('part-visible'),
        e.GIs.classList.add('hidden'),
        e.GIs.classList.remove('part-visible'),
        e.BOo.classList.add('hidden'),
        e.BOo.classList.remove('part-visible'),
        e.oba.classList.add('hide'),
        ia = dc,
        Ga = !1,
        sa(!1),
        Ea = na = !1,
        e.Nh3.classList.remove('hide'),
        !1 !== za &&
        (ba(za).classList.add('high-blur'), za = !1);
    else {
        if (!r) {
            w.push(40);
            Fa = a.getHTML({
                path: [
                    'links',
                    0
                ]
            });
            oa = document.createElement('div');
            oa.classList.add('step');
            b = [];
            for (H = 0; H < w.length; H++) g = a.getHTML({
                path: [
                    'links',
                    w[H],
                    1
                ]
            }),
                g = encodeURI(g),
                u = a.getHTML({
                    path: [
                        'links',
                        w[H],
                        0
                    ]
                }),
                '' !== g &&
                b.push(`<a href="${Fa + g}" target="_blank" class=>\\(${u}\\)</a>`);
            0 != b.length &&
                (
                    f = `<div class="math-links notranslate">${b.join('')}</div>`,
                    oa.innerHTML = f,
                    p.appendChild(oa)
                );
            na &&
                (dc = ia)
        }
        var Ua = function () {
            let Q = '',
                R = '',
                U = document.createElement('span'),
                X = document.createElement('span');
            U.classList.add('ktx-latex-copy');
            X.classList.add('ktx-expr-copy');
            var h = null;
            let t = function () {
                null != h &&
                    clearTimeout(h);
                e.ZAl.classList.remove('hidden');
                e.ZAl.classList.add('part-visible');
                h = setTimeout(
                    function () {
                        e.ZAl.classList.add('hidden');
                        e.ZAl.classList.remove('part-visible')
                    },
                    2000
                )
            };
            U.addEventListener(
                'click',
                y => {
                    try {
                        navigator.clipboard.writeText(Q),
                            t()
                    } catch (z) {
                    }
                }
            );
            X.addEventListener(
                'click',
                y => {
                    try {
                        navigator.clipboard.writeText(R),
                            t()
                    } catch (z) {
                    }
                }
            );
            e.Jnx.append(Q);
            e.Jnx.append(R);
            let q = null;
            return function (y) {
                'click' === y.type &&
                    this.classList.contains('ktx-copy') &&
                    (
                        q &&
                        q.classList.remove('ktx-selected'),
                        this.classList.add('ktx-selected'),
                        q = this,
                        this.appendChild(U),
                        this.appendChild(X),
                        Q = this.dataset.tex,
                        R = this.dataset.expr,
                        U.title = this.dataset.tex,
                        X.title = this.dataset.expr
                    );
                if (
                    !(
                        this.classList.contains('ktx-checked') ||
                        this.parentNode.parentNode.classList.contains('kmethod') ||
                        (
                            this.classList.add('ktx-checked'),
                            y = this.dataset.tex,
                            null == y ||
                            4 > y.length ||
                            y.includes('\\htmlId') ||
                            y.includes('hline')
                        )
                    )
                ) {
                    y = eb(y);
                    var z = Na(y, !0).replace(/!/g, ' | ').replace(/~/g, ' & ');
                    this.dataset.tex = y;
                    this.dataset.expr = z;
                    this.classList.add('ktx-copy');
                    isMobile &&
                        (
                            this.appendChild(U),
                            this.appendChild(X),
                            Q = this.dataset.tex,
                            R = this.dataset.expr,
                            U.title = this.dataset.tex,
                            X.title = this.dataset.expr
                        )
                }
            }
        }(),
            Aa = Array.from(p.getElementsByClassName('ktx'));
        Aa.forEach(
            Q => {
                Q.dataset.tex = Q.innerHTML.slice(2, - 2);
                Q.classList.add('notranslate');
                isMobile ||
                    (
                        Q.addEventListener('mouseenter', Ua),
                        Q.addEventListener('click', Ua)
                    )
            }
        );
        isMobile &&
            !window.isApp &&
            e.Jnx.addEventListener(
                'click',
                Q => {
                    (Q = Q.target.closest('.ktx')) &&
                        Q.matches('.ktx') &&
                        !Q.classList.contains('ktx-selected') &&
                        Ua.call(Q, {
                            type: 'click'
                        })
                }
            );
        var ib = function (Q) {
            if (Q = this.querySelector('.txt')) {
                var R = Q.innerHTML;
                /^\d+$/.test(R) &&
                    (R = c[+ R], R = ac(R));
                Q.innerHTML = R.replace(/\\\(([^\s].*?)\\\)/g, '\\( \\htmlClass{notranslate}{$1}\\)');
                ab(this);
                Q.classList.remove('notranslate')
            }
        };
        [
            ...p.getElementsByClassName('more')
        ].forEach(Q => Q.addEventListener('click', ib, {
            once: !0
        }));
        e.Jnx.replaceChildren ? e.Jnx.replaceChildren() : e.Jnx.textContent = '';
        a = Array.from(p.querySelectorAll('.math-links>a'));
        var pa = Array.from(p.querySelectorAll('.kbx .txt'));
        Aa = Aa.concat(a);
        await (
            async () => {
                const Q = [];
                Aa.forEach(
                    R => {
                        var U = R.textContent.slice(0, 2);
                        if (['\\(',
                            '\\['].includes(U)) {
                            var X = '\\[' === U ? !0 : !1;
                            U = new Promise(
                                h => {
                                    na ? (Ja(R, R.textContent.slice(2, - 2), {
                                        displayMode: X
                                    }), h()) : setTimeout(() => {
                                        Ja(R, R.textContent.slice(2, - 2), {
                                            displayMode: X
                                        });
                                        h()
                                    }, 0)
                                }
                            );
                            Q.push(U)
                        }
                    }
                );
                pa.forEach(
                    R => {
                        if (/\\(\(|\[)/.test(R.textContent)) {
                            var U = new Promise(X => {
                                na ? (ab(R), X()) : setTimeout(() => {
                                    ab(R);
                                    X()
                                }, 0)
                            });
                            Q.push(U)
                        }
                    }
                );
                await Promise.all(Q)
            }
        )();
        e.kJv.style.fontSize = '100%';
        Ib(Ma);
        jb ? jb = !1 : gb -= 1400;
        na ||
            window.isApp ||
            await cc();
        var ja = (Q, R = !1) => R ? p.querySelectorAll(Q) : p.querySelector(Q);
        (
            () => {
                for (
                    var Q = function (q, y) {
                        let z = q[y];
                        if (Array.isArray(z)) if (1 < z.length) for (y = 0; y < z.length; y++) Q(z, y);
                        else 1 == z.length &&
                            Array.isArray(z[0]) &&
                            (q[y] = z[0]);
                        return q
                    },
                    R = function (q, y, z, I, G) {
                        return function (O) {
                            if (!G.flag || cb || this.classList.contains('high-blur')) return !1;
                            G.flag = !1;
                            na = !0;
                            da(ec, ha, !0, !0);
                            for (O = 0; O < q.length; O++) q = Q(q, O);
                            Va = q;
                            Ea = [
                                z,
                                I
                            ];
                            za = y;
                            setTimeout(
                                function () {
                                    Va = q;
                                    Ea = [
                                        z,
                                        I
                                    ];
                                    za = y;
                                    e.nyi.disabled ||
                                        Qa({
                                            isTrusted: !0
                                        });
                                    G.flag = !0
                                },
                                300
                            )
                        }
                    },
                    U = {
                        flag: !0
                    },
                    X = 0,
                    h = 0,
                    t = 0;
                    t < E.length;
                    t++
                ) {
                    let q = '.forced-step-' + t;
                    C[X].includes(t) ||
                        X++;
                    h = C[X].indexOf(t);
                    ja(q).addEventListener('click', R(E[t], q, X, h, U))
                }
                try {
                    J.forEach(
                        q => {
                            let y = q[0];
                            '' !== y &&
                                (
                                    y = rd(y, q[1]),
                                    ja('#partint-' + q[2]).addEventListener('click', z => window.open(y, '_blank'))
                                )
                        }
                    )
                } catch (q) {
                    console.log(q)
                }
                setTimeout(function () {
                    e.Nh3.classList.remove('hide')
                }, 500);
                Ga = !1;
                X = function (q) {
                    var y,
                        z;
                    return function () {
                        setTimeout(
                            function () {
                                q.classList.add('trans-05');
                                q.classList.add('ping');
                                setTimeout(
                                    function () {
                                        q.classList.remove('ping');
                                        setTimeout(function () {
                                            q.classList.remove('trans-05')
                                        }, 300)
                                    },
                                    1000
                                );
                                y = q.getBoundingClientRect().left - document.documentElement.clientWidth / 2;
                                z = q.getBoundingClientRect().top - document.documentElement.clientHeight / 2;
                                window.scrollBy({
                                    top: z,
                                    behavior: 'smooth'
                                });
                                setTimeout(
                                    function () {
                                        e.Jnx.scrollBy({
                                            left: y - 150,
                                            behavior: 'smooth'
                                        })
                                    },
                                    100
                                )
                            },
                            50
                        )
                    }
                };
                for (h = 1; h <= l; h++) R = ja('#formula-' + h),
                    U = ja('#formula-from-' + h),
                    R &&
                    U &&
                    (
                        R.classList.add('pointer-color'),
                        R.classList.add('p-up'),
                        U.classList.add('pointer-color'),
                        U.classList.add('p-down'),
                        R.addEventListener('click', X(U)),
                        U.addEventListener('click', X(R))
                    );
                for (h = 1; h <= n; h++) R = ja('#branch-' + h),
                    U = ja('#branch-from-' + h),
                    R &&
                    U &&
                    (
                        R.classList.add('pointer-color'),
                        R.classList.add('p-up'),
                        U.classList.add('pointer-color'),
                        U.classList.add('p-down'),
                        R.addEventListener('click', X(U)),
                        U.addEventListener('click', X(R))
                    );
                '' != hb &&
                    (R = ja(K('LnJlcGVhdC1vcA=='))) &&
                    R.addEventListener(
                        'click',
                        function (q, y) {
                            var z = location.protocol + '//' + location.hostname + '/der';
                            lang != defaultLang &&
                                (z += '/' + lang);
                            q = q.replace(/_([0-9])/g, '$1');
                            z += '/#expr=' + encodeURIComponent(q) + '&arg=' + encodeURIComponent(y);
                            return function (I) {
                                window.open(z, '_blank')
                            }
                        }(hb, xa)
                    )
            }
        )();
        e.fhn.classList.add('fast-hidden');
        e.oHX.classList.add('hidden');
        e.oHX.classList.remove('part-visible');
        e.Jb1.classList.add('hidden');
        e.Jb1.classList.remove('part-visible');
        e.SHE.classList.add('hidden');
        e.SHE.classList.remove('part-visible');
        e.GIs.classList.add('hidden');
        e.GIs.classList.remove('part-visible');
        e.BOo.classList.add('hidden');
        e.BOo.classList.remove('part-visible');
        (a = document.getElementById('bookmark-container')) &&
            a.classList.add('hide');
        e.K0h.classList.remove('hide');
        if (na) {
            if (a = ja(za)) a.classList.add('new-step'),
                a.parentNode.classList.add('new-step');
            e.Jnx.appendChild(p)
        } else e.oba.classList.add('instanthidden'),
            requestAnimationFrame(
                () => {
                    (
                        async () => {
                            const Q = Array.from(p.children);
                            p = document.createElement('div');
                            e.Jnx.appendChild(p);
                            const R = document.documentElement.clientWidth ||
                                window.innerWidth;
                            await (
                                () => new Promise(
                                    X => {
                                        function h() {
                                            if (q < Q.length) {
                                                const I = document.createDocumentFragment();
                                                var z = [];
                                                for (let G = 0; G < y && q < Q.length; G++) z = z.concat(Array.from(Q[q].getElementsByClassName('ktx'))),
                                                    I.appendChild(Q[q]),
                                                    q++;
                                                t &&
                                                    (e.oba.classList.add('hide'), t = !1);
                                                p.appendChild(I);
                                                z.forEach(
                                                    G => {
                                                        var O = Math.min(G.clientWidth, R);
                                                        let M = G.scrollWidth;
                                                        O < M &&
                                                            (O /= M, 0.7 > O && (O *= 1.2), 0.7 < O && (G.style.fontSize = O + 'em'))
                                                    }
                                                );
                                                q < Q.length ? setTimeout(h, 0) : X()
                                            }
                                        }
                                        let t = !0,
                                            q = 0;
                                        const y = Math.max(5, Math.ceil(Q.length / 4));
                                        setTimeout(h, 0)
                                    }
                                )
                            )();
                            e.oba.classList.add('hide');
                            if (!window.isApp) {
                                var U = e.K0h.getBoundingClientRect().top + window.scrollY;
                                window.scrollTo({
                                    top: U,
                                    behavior: 'smooth'
                                })
                            }
                            va.reveal(ya);
                            fc.observe()
                        }
                    )()
                }
            );
        setTimeout(
            function () {
                sa(!1);
                e.DoP.classList.remove('hide');
                da(e.ru9.value, ha, !0, !0)
            },
            100
        );
        Ea = na = !1
    }
}
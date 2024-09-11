defmodule RenewCollab.Symbol.PredefinedSymbols do
  @symbols [
    %{
      "name" => "rect",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-double",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-double-proportional",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => -0.1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => -0.1
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-double-in",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.5,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "height",
                      "rel_value" => -0.5,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.5,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "width",
                    "rel_value" => 0.5,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "height",
                    "rel_value" => 0.5,
                    "static" => 10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "ellipse",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "ellipse-double",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "ellipse-double-in",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "width",
                    "rel_value" => 0.25,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "pie",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bar-horizontal",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "height",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "height",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bar-vertical",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -1,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "diamond",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-right",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-center-right",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-right",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-left",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-center-left",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-left",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-up",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-center-up",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-up",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-down",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 1
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-center-down",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-half-down",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 1
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-sw",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-ne",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-nw",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "triangle-se",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 1
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "diamond-double-rel",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.7
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.7
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.7
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.7
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.7
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.7
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => -0.2
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "diamond-full-height",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "diamond-full-width",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "diamond-full-height-double",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "diamond-full-width-double",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-clipped",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-round",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "octagon",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.3
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.3
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.3
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.3
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "octagon-proper",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.25
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.25
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.25
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.25
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.25
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.25
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.25
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.25
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => -0.25
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "octagon-square",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => -0.6
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-clipped-paper",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-clipped-paper-proportional",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-fold-paper",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => -20
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-fold-paper-proportional",
      "paths" => [
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "rect-handle",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "width",
                    "rel_value" => 1,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "height",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "height",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black-diamond",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "height",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "height",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black-diamond-fit",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black-diamond-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "height",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "height",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black-diamond-black-fit",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black-diamond-quad",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "height",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "height",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-horizontal-black-diamond-quad-fit",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -1,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black-diamond",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -1,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black-diamond-fit",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black-diamond-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -1,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black-diamond-black-fit",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => -20
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black-diamond-quad",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 1,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -1,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.5,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "bar-vertical-black-diamond-quad-fit",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.25,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "hexagon",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "pill",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "minsize",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bracket-left",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.4,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.4,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.4,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bracket-right",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.4,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.4,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.4,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bracket-both",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.3,
                      "static" => -40
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.3,
                      "static" => -30
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.3,
                      "static" => 40
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.3,
                      "static" => 30
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bracket-left-outer",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bracket-right-outer",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bracket-both-outer",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.45,
                      "static" => -40
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.45,
                      "static" => -40
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.45,
                      "static" => 40
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "minsize",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.45,
                      "static" => 40
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "diamond-plus",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.25
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "diamond-plus-big",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 5
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -5
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.3,
                      "static" => 30
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 5
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 5
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.3,
                      "static" => 30
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -5
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 5
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.3,
                      "static" => -30
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -5
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -5
                    },
                    "unit" => "width",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.3,
                      "static" => -30
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.3,
                    "static" => -30
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "diamond-X",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.17
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.22
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "rect-double-black",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => -10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "rect-double-proportional-black",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "maxsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => -0.1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "maxsize",
                  "value" => -0.1
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "rect-double-in-black",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.5,
                      "static" => -10
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "height",
                      "rel_value" => -0.5,
                      "static" => -10
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.5,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "width",
                    "rel_value" => 0.5,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "height",
                    "rel_value" => 0.5,
                    "static" => 10
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "ellipse-double-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "ellipse-double-in-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "ellipse-triple-black",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "sum",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "ellipse-mail",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.6
                  }
                },
                %{
                  "relative" => true
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.6
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.3
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.2
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "ellipse-mail-filled",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -6
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.6
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.1,
                    "static" => 6
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.6
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "cross",
      "paths" => [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.17
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.22
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "rect-fold-paper-proportional-striped",
      "paths" => [
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "none",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "none",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.6
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.2,
                    "static" => 15
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.9
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.6
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.9
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.6
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "minsize",
                    "rel_value" => -0.2,
                    "static" => -15
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.9
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "rect-fold-paper-proportional-arrow-right",
      "paths" => [
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.4,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.9
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.4,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.9
                  }
                },
                %{
                  "relative" => true
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.2
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.8
                }
              }
            }
          ],
          "stroke_color" => "black"
        }
      ]
    },
    %{
      "name" => "rect-fold-paper-proportional-arrow-right-black",
      "paths" => [
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.4
                }
              }
            }
          ],
          "stroke_color" => "black"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.4,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.9
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "sum",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.4,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.9
                  }
                },
                %{
                  "relative" => true
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.2
                },
                "y" => %{
                  "offset" => %{
                    "op" => "sum",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.8
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "double-arrow",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.4
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.3
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.3
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.6
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.6
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.3
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "cone-arrow",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.2
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.2
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.2
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.2
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "cylinder",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.6
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.2
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "none",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },

                %{"relative" => false},
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.2
                }
              }
            },
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "database",
      "paths" => [
        %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.6
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{"relative" => false},
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.2
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "none",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.2
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.2
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bpmn-activity",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bpmn-activity-exchange",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0
                  },
                  "arc" => %{
                    "angle" => 0,
                    "sweep" => false,
                    "large" => true,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => 0
                    }
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.5,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bpmn-gateway",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
    %{
      "name" => "bpmn-gateway-xor",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.1
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.25
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bpmn-gateway-and",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -0.5
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => -0.5
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.05
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.05
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.17
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.17
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.17
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.22
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
    },
    %{
      "name" => "bpmn-pool",
      "paths" => [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                },
                %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  }
                },
                %{
                  "relative" => false
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => false,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "width",
                    "rel_value" => 1,
                    "static" => 20
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
    },
  ]

  def generate_bpmn_symbols() do
    for pos <- ["start", "interm", "end"],
        type <- ["standard", "message", "terminate"],
        throwing <- [true, false]
        # , 
        # (type == "message" or not throwing) and 
        # (pos != "start" or not throwing) and 
        # (pos != "end" or throwing or type != "message") and 
        # (type != "terminate" or pos == "end")
         do
      name =
        "bpmn-#{pos}-#{type}" |> then(&if throwing, do: "#{&1}-throwing", else: &1)

      %{
        "name" => name,
        "paths" => case pos do
          "start" ->  [
        %{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "inherit"
        }
      ]
          "interm" -> [
          %{
            "fill_color" => "inherit",
            "segments" => [
              %{
                "steps" => [
                  %{
                    "arc" => %{
                      "angle" => 0,
                      "large" => false,
                      "rx" => %{
                        "offset" => %{
                          "op" => "min",
                          "rel_unit" => "minsize",
                          "rel_value" => 0,
                          "static" => 0
                        },
                        "unit" => "width",
                        "value" => 0.5
                      },
                      "ry" => %{
                        "offset" => %{
                          "op" => "min",
                          "rel_unit" => "minsize",
                          "rel_value" => 0,
                          "static" => 0
                        },
                        "unit" => "height",
                        "value" => 0.5
                      },
                      "sweep" => false
                    },
                    "relative" => true,
                    "x" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 1
                    }
                  },
                  %{
                    "arc" => %{
                      "angle" => 0,
                      "large" => false,
                      "rx" => %{
                        "offset" => %{
                          "op" => "min",
                          "rel_unit" => "minsize",
                          "rel_value" => 0,
                          "static" => 0
                        },
                        "unit" => "width",
                        "value" => 0.5
                      },
                      "ry" => %{
                        "offset" => %{
                          "op" => "min",
                          "rel_unit" => "minsize",
                          "rel_value" => 0,
                          "static" => 0
                        },
                        "unit" => "height",
                        "value" => 0.5
                      },
                      "sweep" => false
                    },
                    "relative" => true,
                    "x" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => -1
                    }
                  }
                ],
                "start" => %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                }
              }
            ],
            "stroke_color" => "inherit"
          },
          %{
            "fill_color" => "inherit",
            "segments" => [
              %{
                "steps" => [
                  %{
                    "arc" => %{
                      "angle" => 0,
                      "large" => false,
                      "rx" => %{
                        "offset" => %{
                          "op" => "max",
                          "rel_unit" => "width",
                          "rel_value" => -0.25,
                          "static" => -10
                        },
                        "unit" => "width",
                        "value" => 0.5
                      },
                      "ry" => %{
                        "offset" => %{
                          "op" => "max",
                          "rel_unit" => "height",
                          "rel_value" => -0.25,
                          "static" => -10
                        },
                        "unit" => "height",
                        "value" => 0.5
                      },
                      "sweep" => false
                    },
                    "relative" => true,
                    "x" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.5,
                        "static" => -20
                      },
                      "unit" => "width",
                      "value" => 1
                    }
                  },
                  %{
                    "arc" => %{
                      "angle" => 0,
                      "large" => false,
                      "rx" => %{
                        "offset" => %{
                          "op" => "max",
                          "rel_unit" => "width",
                          "rel_value" => -0.25,
                          "static" => -10
                        },
                        "unit" => "width",
                        "value" => 0.5
                      },
                      "ry" => %{
                        "offset" => %{
                          "op" => "max",
                          "rel_unit" => "height",
                          "rel_value" => -0.25,
                          "static" => -10
                        },
                        "unit" => "height",
                        "value" => 0.5
                      },
                      "sweep" => false
                    },
                    "relative" => true,
                    "x" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "width",
                        "rel_value" => 0.5,
                        "static" => 20
                      },
                      "unit" => "width",
                      "value" => -1
                    }
                  }
                ],
                "start" => %{
                  "relative" => false,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.25,
                      "static" => 10
                    },
                    "unit" => "width",
                    "value" => 0
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "height",
                    "value" => 0.5
                  }
                }
              }
            ],
            "stroke_color" => "inherit"
          }
        ]
        "end" -> [%{
          "fill_color" => "inherit",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        },
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "min",
                        "rel_unit" => "minsize",
                        "rel_value" => 0,
                        "static" => 0
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "width",
                      "rel_value" => 0.5,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => -1
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "width",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.5
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "height",
                        "rel_value" => -0.25,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.5
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "width",
                      "rel_value" => -0.5,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 1
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "max",
                    "rel_unit" => "width",
                    "rel_value" => -0.25,
                    "static" => -10
                  },
                  "unit" => "width",
                  "value" => 1
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
      end |> Enum.concat(
        case type do
          "standard" -> []
          "message" -> if(throwing, do: [
          %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.1,
                      "static" => -6
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.6
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.1,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.1,
                    "static" => 6
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.6
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }], else: [
          %{
          "fill_color" => "white",
          "segments" => [
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.2
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.6
                  }
                },
                %{
                  "relative" => true
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "width",
                  "value" => 0.5
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            },
            %{
              "steps" => [
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.6
                  }
                },
                %{
                  "relative" => true,
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => -0.4
                  }
                },
                %{
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.3
                  },
                  "y" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0,
                      "static" => 0
                    },
                    "unit" => "minsize",
                    "value" => 0.2
                  }
                }
              ],
              "start" => %{
                "relative" => true,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => 0.3
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "minsize",
                  "value" => -0.2
                }
              }
            }
          ],
          "stroke_color" => "black"
        }])       
        "terminate" ->  [
        %{
          "fill_color" => "black",
          "segments" => [
            %{
              "steps" => [
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "minsize",
                        "rel_value" => -0.1,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.3
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "minsize",
                        "rel_value" => -0.1,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.3
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "max",
                      "rel_unit" => "minsize",
                      "rel_value" => -0.2,
                      "static" => -20
                    },
                    "unit" => "width",
                    "value" => 0.6
                  }
                },
                %{
                  "arc" => %{
                    "angle" => 0,
                    "large" => false,
                    "rx" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "minsize",
                        "rel_value" => -0.1,
                        "static" => -10
                      },
                      "unit" => "width",
                      "value" => 0.3
                    },
                    "ry" => %{
                      "offset" => %{
                        "op" => "max",
                        "rel_unit" => "minsize",
                        "rel_value" => -0.1,
                        "static" => -10
                      },
                      "unit" => "height",
                      "value" => 0.3
                    },
                    "sweep" => false
                  },
                  "relative" => true,
                  "x" => %{
                    "offset" => %{
                      "op" => "min",
                      "rel_unit" => "minsize",
                      "rel_value" => 0.2,
                      "static" => 20
                    },
                    "unit" => "width",
                    "value" => -0.6
                  }
                }
              ],
              "start" => %{
                "relative" => false,
                "x" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0.1,
                    "static" => 10
                  },
                  "unit" => "width",
                  "value" => 0.2
                },
                "y" => %{
                  "offset" => %{
                    "op" => "min",
                    "rel_unit" => "minsize",
                    "rel_value" => 0,
                    "static" => 0
                  },
                  "unit" => "height",
                  "value" => 0.5
                }
              }
            }
          ],
          "stroke_color" => "none"
        }
      ]
        end
      )
      }
    end
  end

  def all do
    @symbols
    |> Enum.concat(generate_bpmn_symbols())
    |> Enum.map(fn shape ->
      shape
      |> Map.update("paths", [], fn paths ->
        paths
        |> Enum.with_index()
        |> Enum.map(fn
          {path, path_index} ->
            Map.put(path, "sort", path_index)
            |> Map.update("segments", [], fn segments ->
              segments
              |> Enum.with_index()
              |> Enum.map(fn
                {segment, segment_index} ->
                  Map.new()
                  |> Map.put(
                    "relative",
                    segment |> Map.get("start") |> Map.get("relative", false)
                  )
                  |> Map.put("sort", segment_index)
                  |> Map.put(
                    "x_value",
                    segment |> Map.get("start") |> Map.get("x") |> Map.get("value")
                  )
                  |> Map.put(
                    "x_unit",
                    segment |> Map.get("start") |> Map.get("x") |> Map.get("unit")
                  )
                  |> Map.put(
                    "x_offset_operation",
                    segment
                    |> Map.get("start")
                    |> Map.get("x")
                    |> Map.get("offset")
                    |> Map.get("op", "sum")
                  )
                  |> Map.put(
                    "x_offset_value_static",
                    segment
                    |> Map.get("start")
                    |> Map.get("x")
                    |> Map.get("offset")
                    |> Map.get("static")
                  )
                  |> Map.put(
                    "x_offset_dynamic_value",
                    segment
                    |> Map.get("start")
                    |> Map.get("x")
                    |> Map.get("offset")
                    |> Map.get("rel_value")
                  )
                  |> Map.put(
                    "x_offset_dynamic_unit",
                    segment
                    |> Map.get("start")
                    |> Map.get("x")
                    |> Map.get("offset")
                    |> Map.get("rel_unit")
                  )
                  |> Map.put(
                    "y_value",
                    segment |> Map.get("start") |> Map.get("y") |> Map.get("value")
                  )
                  |> Map.put(
                    "y_unit",
                    segment |> Map.get("start") |> Map.get("y") |> Map.get("unit")
                  )
                  |> Map.put(
                    "y_offset_operation",
                    segment
                    |> Map.get("start")
                    |> Map.get("y")
                    |> Map.get("offset")
                    |> Map.get("op", "sum")
                  )
                  |> Map.put(
                    "y_offset_value_static",
                    segment
                    |> Map.get("start")
                    |> Map.get("y")
                    |> Map.get("offset")
                    |> Map.get("static")
                  )
                  |> Map.put(
                    "y_offset_dynamic_value",
                    segment
                    |> Map.get("start")
                    |> Map.get("y")
                    |> Map.get("offset")
                    |> Map.get("rel_value")
                  )
                  |> Map.put(
                    "y_offset_dynamic_unit",
                    segment
                    |> Map.get("start")
                    |> Map.get("y")
                    |> Map.get("offset")
                    |> Map.get("rel_unit")
                  )
                  |> Map.put(
                    "steps",
                    Map.get(segment, "steps", [])
                    |> Enum.with_index()
                    |> Enum.map(fn
                      {step, step_index} ->
                        Map.new()
                        |> Map.put("sort", step_index)
                        |> Map.put("relative", Map.get(step, "relative", false))
                        |> then(fn
                          step_map ->
                            case Map.get(step, "y") do
                              nil ->
                                step_map

                              %{
                                "offset" => %{
                                  "op" => op,
                                  "rel_unit" => rel_unit,
                                  "rel_value" => rel_value,
                                  "static" => static
                                },
                                "unit" => unit,
                                "value" => value
                              } ->
                                step_map
                                |> Map.put(
                                  "vertical",
                                  Map.new()
                                  |> Map.put("y_value", value)
                                  |> Map.put("y_unit", unit)
                                  |> Map.put("y_offset_operation", op)
                                  |> Map.put("y_offset_value_static", static)
                                  |> Map.put("y_offset_dynamic_value", rel_value)
                                  |> Map.put("y_offset_dynamic_unit", rel_unit)
                                )
                            end
                        end)
                        |> then(fn
                          step_map ->
                            case Map.get(step, "x") do
                              nil ->
                                step_map

                              %{
                                "offset" => %{
                                  "op" => op,
                                  "rel_unit" => rel_unit,
                                  "rel_value" => rel_value,
                                  "static" => static
                                },
                                "unit" => unit,
                                "value" => value
                              } ->
                                step_map
                                |> Map.put(
                                  "horizontal",
                                  Map.new()
                                  |> Map.put("x_value", value)
                                  |> Map.put("x_unit", unit)
                                  |> Map.put("x_offset_operation", op)
                                  |> Map.put("x_offset_value_static", static)
                                  |> Map.put("x_offset_dynamic_value", rel_value)
                                  |> Map.put("x_offset_dynamic_unit", rel_unit)
                                )
                            end
                        end)
                        |> then(fn
                          step_map ->
                            case Map.get(step, "arc") do
                              nil ->
                                step_map

                              %{
                                "angle" => angle,
                                "large" => large,
                                "rx" => %{
                                  "offset" => %{
                                    "op" => rx_op,
                                    "rel_unit" => rx_rel_unit,
                                    "rel_value" => rx_rel_value,
                                    "static" => rx_static
                                  },
                                  "unit" => rx_unit,
                                  "value" => rx_value
                                },
                                "ry" => %{
                                  "offset" => %{
                                    "op" => ry_op,
                                    "rel_unit" => ry_rel_unit,
                                    "rel_value" => ry_rel_value,
                                    "static" => ry_static
                                  },
                                  "unit" => ry_unit,
                                  "value" => ry_value
                                },
                                "sweep" => sweep
                              } ->
                                step_map
                                |> Map.put(
                                  "arc",
                                  Map.new()
                                  |> Map.put("rx_value", rx_value)
                                  |> Map.put("rx_unit", rx_unit)
                                  |> Map.put("rx_offset_operation", rx_op)
                                  |> Map.put("rx_offset_value_static", rx_static)
                                  |> Map.put("rx_offset_dynamic_value", rx_rel_value)
                                  |> Map.put("rx_offset_dynamic_unit", rx_rel_unit)
                                  |> Map.put("ry_value", ry_value)
                                  |> Map.put("ry_unit", ry_unit)
                                  |> Map.put("ry_offset_operation", ry_op)
                                  |> Map.put("ry_offset_value_static", ry_static)
                                  |> Map.put("ry_offset_dynamic_value", ry_rel_value)
                                  |> Map.put("ry_offset_dynamic_unit", ry_rel_unit)
                                  |> Map.put("sweep", sweep)
                                  |> Map.put("large", large)
                                  |> Map.put("angle", angle)
                                )
                            end
                        end)
                    end)
                  )
              end)
            end)
        end)
      end)
    end)
  end
end

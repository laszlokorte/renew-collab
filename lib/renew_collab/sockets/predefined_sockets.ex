defmodule RenewCollab.Sockets.PredefinedSockets do
  @socket_schemas [
    %{
      id: "0f59a84e-8569-4272-839f-788ab07eca23",
      name: "simple",
      sockets: [
        %{
          id: "F4A7F504-8EEA-4F7E-B140-E33A9C8C8F71",
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        }
      ]
    },
    %{
      id: "4FDF577B-DB81-462E-971E-FA842F0ABA1E",
      name: "simple-rect",
      stencil: "rect",
      sockets: [
        %{
          id: "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        }
      ]
    },
    %{
      id: "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC",
      name: "simple-ellipse",
      stencil: "ellipse",
      sockets: [
        %{
          id: "9BE09A98-DECF-4D38-8A06-5381B51D7538",
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        }
      ]
    },
    %{
      id: "11062480-803E-4944-AE74-DF3EF8978187",
      name: "sides",
      sockets: [
        %{
          id: "DD6B5997-DEFE-4F58-A05B-4EF3571959E5",
          name: "left",
          x_value: 0,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "194279C9-FD29-48D8-B8B7-1E2E6EE5A1ED",
          name: "right",
          x_value: 1,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "B88AD3EB-8743-4192-9915-ED2C3A738FF5",
          name: "top",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "EEE36E06-7B2A-44F2-B30D-EEAA44E26244",
          name: "bottom",
          x_value: 0.5,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        }
      ]
    },
    %{
      id: "46BEAB25-389D-4E4B-8E13-5C5B34A8C20A",
      name: "corners",
      sockets: [
        %{
          id: "7A2214DF-EC36-4D49-BEE9-924CB9FB8338",
          name: "topleft",
          x_value: 0,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "A853DFF0-7BD3-4AAC-84C3-EA8EBF29D7C8",
          name: "topright",
          x_value: 1,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "BA44AE78-54C6-4BE5-8427-3B92B1D492C3",
          name: "bottomleft",
          x_value: 0,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        },
        %{
          id: "AD59F5BA-E09A-43F8-92D1-DB798F095F70",
          name: "bottomright",
          x_value: 1,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        }
      ]
    },
    %{
      id: "A1A1BD97-373D-4B78-B218-D20F1C5BDB35",
      name: "corners-and-sides",
      sockets: [
        %{
          id: "95AE59EF-A4F5-4F2A-9605-1F838A783D4E",
          name: "topleft",
          x_value: 0,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "BC72DECD-8111-46B4-9EE3-8940A4FBDFF1",
          name: "topright",
          x_value: 1,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "673F891D-CA67-433B-B45B-BA50D27D2A4D",
          name: "bottomleft",
          x_value: 0,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        },
        %{
          id: "4D1E1ED2-DF9F-45CF-A1D8-E58CD63C860D",
          name: "bottomright",
          x_value: 1,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        },
        %{
          id: "55874318-73F0-468F-A2F9-B40109FDABAF",
          name: "left",
          x_value: 0,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "7F6600AA-FBAD-42B9-B0B5-3C26EAE99822",
          name: "right",
          x_value: 1,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "43BB50CC-1D89-44CA-A41B-B7054232B3CA",
          name: "top",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "3AD18947-AFBD-47F0-8B82-27528AD9E4C8",
          name: "bottom",
          x_value: 0.5,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        }
      ]
    },
    %{
      id: "5D768A61-6992-4350-864E-DCC4B2219181",
      name: "sides-and-center",
      sockets: [
        %{
          id: "AE24ADB9-3BD7-4511-BFC8-F7398AFCE669",
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "532C2826-2325-4703-9589-7C8D943F1B61",
          name: "left",
          x_value: 0,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "3753A35F-101D-48E4-9BB2-75E9378105F4",
          name: "right",
          x_value: 1,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "D7E255EC-BC71-41C2-B56D-0BEDC3B759ED",
          name: "top",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "C3518EAD-E81F-4F34-953C-19C04C4AE02B",
          name: "bottom",
          x_value: 0.5,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        }
      ]
    },
    %{
      id: "737FD22C-A3C2-4962-B869-CBE867F1F748",
      name: "corners-and-center",
      sockets: [
        %{
          id: "F50CD3AF-C66E-468D-B15A-B4316494C5C0",
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "4D7F9822-BC1D-4E81-B26B-B64D4A025B5A",
          name: "topleft",
          x_value: 0,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "27942DC6-FA78-44A7-AC9A-6B587F141603",
          name: "topright",
          x_value: 1,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "5AB78898-CC93-4173-A6B5-FB2B2533E899",
          name: "bottomleft",
          x_value: 0,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        },
        %{
          id: "B8762481-A1A5-4B86-B283-79E73ED59073",
          name: "bottomright",
          x_value: 1,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        }
      ]
    },
    %{
      id: "4A513B13-F04E-4E4C-9655-EF510DDAAE29",
      name: "3x3 sockets",
      sockets: [
        %{
          id: "180D7C12-EB46-4D19-BE88-2CA9005F57FC",
          name: "center-socket",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "2B635A91-C06C-4108-99C9-99108D89EB09",
          name: "topleft",
          x_value: 0,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "C897A628-78B3-43BA-9327-37A857D5C9D7",
          name: "topright",
          x_value: 1,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "74B9C965-061F-47E4-BD46-17288F4AE5D0",
          name: "bottomleft",
          x_value: 0,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        },
        %{
          id: "1E5867A8-E387-4239-BF1B-66725FA38B73",
          name: "bottomright",
          x_value: 1,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        },
        %{
          id: "91847090-DAE6-488F-88CD-8B4ECADC78CF",
          name: "left",
          x_value: 0,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "3A3E3B57-5859-4036-9CC2-878B42F78CC7",
          name: "right",
          x_value: 1,
          x_unit: :width,
          y_value: 0.5,
          y_unit: :height
        },
        %{
          id: "75813184-C6B4-4A54-B2EE-516EC217DFB7",
          name: "top",
          x_value: 0.5,
          x_unit: :width,
          y_value: 0,
          y_unit: :height
        },
        %{
          id: "A89F75AF-70D4-4B78-9D10-14C7E2EDFCF6",
          name: "bottom",
          x_value: 0.5,
          x_unit: :width,
          y_value: 1,
          y_unit: :height
        }
      ]
    }
  ]
  def all do
    @socket_schemas
  end
end

object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 294
  Width = 355
  object conn: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\Giovandro\Documents\Embarcadero\Studio\Project' +
        's\Mobile 360\DB\pedidos.db'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 16
    Top = 24
  end
  object qry_geral: TFDQuery
    Connection = conn
    Left = 64
    Top = 24
  end
  object qry_pedido: TFDQuery
    Connection = conn
    Left = 120
    Top = 24
  end
  object qry_cliente: TFDQuery
    Connection = conn
    Left = 64
    Top = 88
  end
  object qry_notificacao: TFDQuery
    Connection = conn
    Left = 192
    Top = 88
  end
  object qry_produto: TFDQuery
    Connection = conn
    Left = 184
    Top = 24
  end
end

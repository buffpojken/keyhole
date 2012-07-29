xml.instruct! :xml, :version => '1.1'
xml.Response do        
  xml.Dial @number, {'callerId' => '+46702267868'}
end
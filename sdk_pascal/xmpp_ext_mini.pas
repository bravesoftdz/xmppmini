unit xmpp_ext_mini;

//xmpp mini ����ڱ�׼ xmpp ���е���չ//��Ҫ����Ϣ���һЩ��������Ѱַ����

interface

//ͼƬ��Ϣ//��չ
function xmpp_mini_EncodeMsg_Image(url:string):string;

implementation

//����� s �Ǽ�ֵ�ԵĶ����ı�����
//url=http://123.com
//
function xmpp_mini_Encode(s:string):string;
begin
  //
  Result := '[xmpp_mini]' + s + '[xmpp_mini_end]';
end;


//ͼƬ��Ϣ//��չ
function xmpp_mini_EncodeMsg_Image(url:string):string;
var
  s:string;
begin
  //
  s := 'desc=' + 'ͼƬ��ַ��չ��Ϣ' + #13#10;
  s := s + 'type=' + 'image' + #13#10;
  s := s + 'image_src=' + url + #13#10;

  Result := xmpp_mini_Encode(s);
end;  


end.

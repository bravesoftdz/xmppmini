unit xmpp_socket;

//xmpp ͨѶ��

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  EncdDecd,
  IdTCPClient, Sockets, WinSock;




function xmpp_login_string(user, pass:string): string;
//���Դ�Сд
function FindStr(subs, s:string):Boolean;

//�����յ����¼�
//- (void)on_recv:(NSString *)s  //�ο� ios �汾
procedure xmpp_on_recv();

//������һ���ڵ�����ݺ�Ҫ������ճ�����������ʵ xmpp ��Ϣһ�㶼��С���򵥵�ֱ�����Ҳ�ǿ��Ե�
procedure xmpp_clear_one_node();

//�Խڵ��ַ���Ϊ�ָ�ȥ��ǰ�洦���������
procedure xmpp_clear_one_node_END_STRING(node_end_string:string);

//����ʱҪ��պ���������
procedure xmpp_reset();

//ȡ����
function GetHost(user_name:string):string;

//���� openfire ��������˵����֤ʱ���û������ܴ�����//�����������ķ�������˵��û��Ǵ���
function GetUser_NotHost(user_name:string):string;

//ͬ ios �汾�ĺ�����
function xmpp_send_string(s:string):Integer;

//������Ϣʱ���ַ���
function xmpp_string_message(from, _to, msg:string): string;


//�򵥵İѵ������ű��˫����
function xmpp_format(s:string):string;

//�ͻ��˷��͸���������������
function xmpp_ping_client2server_string(user:string): string;


//��ʵֱ�Ӳο� ios �汾�� �Ϳ����ˣ�����Ч,�� ViewController_login.m �� uThreadLogin.m ��

var
  gSo:TSocket = -1;
  gXmppHost:string = ''; //xmpp Э���е����������� newbt.net
  gXmppBindId:string = ''; //xmpp Э���еİ� id
  gXmppFullJid:string = ''; //xmpp Э���еİ󶨺󷵻ص�ȫ jid ����
  //gClient:TNBClient;
  gAtConnect:Boolean = False; //�Ƿ���������
  gIsConnect:Boolean = False;
  gRecvBuf:string = ''; //���ջ�����

  gRecvHaveOnePack:Boolean = False; //�ϴ����ݰ����Ƿ���һ�����������ݽڵ㣬����еĻ����Ȳ�æ�ٴζ�ȡ��Ӧ���ٳ��Կ����Ƿ��ܽ�����
  //��һ��������Ϊ�п��ܷ�����һ�η���������������//����紦��һ���Ļ��ͻᷢ���´ζ�ȡʱ��õ���εĵڶ�����
  //����Է�����������Ϣʱ���ͻ��˻���ֹ�������

  

  xmpp_atLogin:Boolean = False; //���� xmppStream.atLogin
  xmpp_isLoginOk:Boolean = False;
  xmpp_atBind:Boolean = False;
  xmpp_xmpp_jid:string = '';
  xmpp_atSession:Boolean = False;

implementation

uses
  form_log, //ֻ��Ϊ�� addlog �������ѣ������ñ�Ĵ�����ļ򵥴��棬��Щ���������߳��е��õĲ��ÿ�����־�Ͱ�ȫ����
  socketplus, functions, xmpp_xml;


var
  xmpp_xmpp_id:Integer = 1; //�ۼ��õģ���û��̫������  

//����ʱҪ��պ���������
procedure xmpp_reset();
begin

  gSo:= -1;
  gXmppHost:= ''; //xmpp Э���е����������� newbt.net
  gXmppBindId:= ''; //xmpp Э���еİ� id
  gXmppFullJid:= ''; //xmpp Э���еİ󶨺󷵻ص�ȫ jid ����
  //gClient:TNBClient;
  gAtConnect:= False; //�Ƿ���������
  gIsConnect:= False;
  gRecvBuf:= ''; //���ջ�����

  xmpp_atLogin:= False; //���� xmppStream.atLogin
  xmpp_isLoginOk:=False; //�Ƿ��¼�ɹ�
end;  

function base64encode(s:string):string;
begin
  Result := EncdDecd.EncodeString(s);

  Result := StringReplace(Result, #13#10, '', [rfIgnoreCase, rfReplaceAll]);

end;

function base64decode(s:string):string;
begin
  Result := EncdDecd.DecodeString(s);
end;

//ȡ����
function GetHost(user_name:string):string;
begin
  Result := get_value(user_name, '@', '');

  //����Դ id �Ļ�Ҫ��ɾ����
  if FindStr('/', Result) then
  begin
    Result := get_value(Result, '', '/');
  end;  

end;

//���� openfire ��������˵����֤ʱ���û������ܴ�����//�����������ķ�������˵��û��Ǵ���
//�������ڴ�����Ҳ�ǿ��Ե�
function GetUser_NotHost(user_name:string):string;
begin
  //Result := get_value(user_name, '@', '');
  Result := get_value(user_name, '', '@');

  //����Դ id �Ļ�Ҫ��ɾ����
  if FindStr('/', Result) then
  begin
    Result := get_value(Result, '', '/');
  end;  

end;


//��¼ʱ�������ַ���
function xmpp_login_string(user, pass:string): string;
begin
  //<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">c3lzYWRtaW4Ac3lzYWRtaW4AMTIz</auth>
  //   Implements the PLAIN server-side mechanism. (RFC 4616)
  //client ----- {authzid, authcid, password} -----> server  //���������� '�û���'0'�û���'0'����'  �͵�¼�ɹ���,�������� #0 ���ָ����ַ�
////  Memo2.Lines.Add('<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + base64encode('t1'#0't1'#0'1') + '</auth>');

  Result := '<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + base64encode(user + #0 + user + #0 + pass) + '</auth>';
  //��֣����� ejabberd-19.08-windows Ҫȥ����һ�� authzid
  Result := '<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + base64encode('' + #0 + user + #0 + pass) + '</auth>';

end;

//�ͻ��˷��͸���������������
function xmpp_ping_client2server_string(user:string):string;
var
  s_id:string;
begin
  //<iq from='juliet@capulet.lit/balcony' to='capulet.lit' id='c2s1' type='get'>
  //  <ping xmlns='urn:xmpp:ping'/>
  //</iq>

  xmpp_xmpp_id := xmpp_xmpp_id + 1;
  s_id := IntToStr(xmpp_xmpp_id);

  //gXmppFullJid Ŀǰ��ʵ�Ǻ� xmpp_xmpp_jid ��ͬ��

  Result := '<iq from="' + xmpp_xmpp_jid + '" to="' + GetHost(xmpp_xmpp_jid)  + '" id="' + s_id + '" type="get">' +
    '<ping xmlns="urn:xmpp:ping"/>' +
    '</iq>' +
    '';

  //--------------------------------------------------------
  //ע�⣬��ʱ��Ļ�Ӧ���п��ܺ������Ļ�Ӧ��ͻ�ģ�����ֻ�кͿͻ��� id ��ͬ�Ĳ��������Ϣ�Ļ�Ӧ
  //<iq from='capulet.lit' to='juliet@capulet.lit/balcony' id='c2s1' type='result'/>

  //��Э�鲻֧��Ӧ�û�Ӧ�������ݣ�����ʵ���ϲ�һ�������Բ����������
  //<iq from='capulet.lit' to='juliet@capulet.lit/balcony' id='c2s1' type='error'>
  //  <ping xmlns='urn:xmpp:ping'/>
  //  <error type='cancel'>
  //    <service-unavailable xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
  //  </error>
  //</iq>

end;

//������Ϣʱ���ַ���
function xmpp_string_message(from, _to, msg:string): string;
begin
  //<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">c3lzYWRtaW4Ac3lzYWRtaW4AMTIz</auth>
  //   Implements the PLAIN server-side mechanism. (RFC 4616)
  //client ----- {authzid, authcid, password} -----> server  //���������� '�û���'0'�û���'0'����'  �͵�¼�ɹ���,�������� #0 ���ָ����ַ�
////  Memo2.Lines.Add('<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + base64encode('t1'#0't1'#0'1') + '</auth>');

  Result := '<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + base64encode(from + #0 + from + #0 + from) + '</auth>';
  //��֣����� ejabberd-19.08-windows Ҫȥ����һ�� authzid
  Result := '<auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + base64encode('' + #0 + from + #0 + from) + '</auth>';

  //<message to='ccc@newbt.net' from="ccc2@newbt.net/Spark" type='chat'><body>hhhhhhhhhhh</body><x xmlns="jabber:x:event"><offline/><composing/></x><active xmlns='http://jabber.org/protocol/chatstates'/></message>
  Result := '<message to="' + _to + '" from="' + from + '/xmppmini" type="chat"><body>' +
  msg +
  '</body><x xmlns="jabber:x:event"><offline/><composing/></x><active xmlns="http://jabber.org/protocol/chatstates"/></message>';

end;


//�򵥵İѵ������ű��˫����
function xmpp_format(s:string):string;
begin
  s := StringReplace(s, #39, '"', [rfReplaceAll]);

  Result := s;
end;  


//���Դ�Сд
function FindStr(subs, s:string):Boolean;
begin
  s := LowerCase(s);         //��ʵ�� xmpp Э��ĽǶ���˵��תҲ�ǿ����ǣ�����Ϊ���㷨ͨ�û���תһ�º��Դ�Сд�ȽϺ�
  subs := LowerCase(subs);

  Result := Pos(subs, s)>0;
end;

//������һ���ڵ�����ݺ�Ҫ������ճ�����������ʵ xmpp ��Ϣһ�㶼��С���򵥵�ֱ�����Ҳ�ǿ��Ե�
procedure xmpp_clear_one_node();
begin
  gRecvBuf := '';
end;

//�Խڵ��ַ���Ϊ�ָ�ȥ��ǰ�洦���������
//xmpp_clear_one_node_END_STRING('message>');
//function xmpp_clear_one_node(s:string):string;
//��ʵ���� xmpp ��˵һ��ֻ���ڶԷ��������ٷ��Ͷ����Ϣ�� message �ڵ��У�������ʱ��ֱ�����Ҳ�ǿ��Ե�
procedure xmpp_clear_one_node_END_STRING(node_end_string:string);
var
  s:string;
begin
  s := gRecvBuf;

  s := get_value(s, node_end_string, '');

  gRecvBuf := s;
end;


//ͬ ios �汾�ĺ�����
procedure clearRecvBuf;
begin
  xmpp_clear_one_node()
end;

//ͬ ios �汾�ĺ�����
function xmpp_send_string(s:string):Integer;
begin
  AddLog('�ͻ��˷���:' + s);
  //Result := socketplus.SendBuf(gSo, s);
  Result := socketplus.SendBuf_TimeOut(gSo, s, 5); //5 ����㹻���� 260k �� Form.pas ��
end;


//�����յ����¼�
//- (void)on_recv:(NSString *)s  //�ο� ios �汾
procedure xmpp_on_recv();
var
  s:string;
  first_login:string;
  resource_bind:string;
  s_id:string;
  ss:string;
  s_presence:string;
begin
  //����ֱ��ʹ�� gRecvBuf ���Բ���Ҫ���ݲ�����

  s := gRecvBuf;

  //</mechanism> ������֤��ʶ
  //if ("</mechanism>")
  if FindStr('</mechanism>', s) then
  begin
    //NSLog(@"������֤��ʶ");
    AddLog('������֤��ʶ') ;
  end;

  //��¼ʧ�ܷ�������Ӧ�� '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized></not-authorized></failure>'
  //�ɹ����� '<success'

  //��¼�ɹ�����Ҫ�ٷ���һ�ε�һ�������ͷ�ַ�������ʱ�� xmpp �������Ļ�Ӧ���ǲ�ͬ����
  if FindStr('<failure', s) then
  begin
    //NSLog(@"������֤��ʶ");
    AddLog('��¼ʧ��') ;
  end;


    //--------------------------------------
    //���ڵ�¼��
    if (xmpp_atLogin = true) then begin
        
        if FindStr('<success', s ) then begin
            
            AddLog('��¼�ɹ�');
            clearRecvBuf(); ////��ս��ջ���
            
            xmpp_isLoginOk := true;
            
            //NSString * first_login = @"<stream:stream to=\"117.169.20.236\" xmlns=\"jabber:client\" xmlns:stream=\"http://etherx.jabber.org/streams\" version=\"1.0\">";

            //openfire ���ԣ�ejabberd-19.08-windows ����
            //first_login := '<stream:stream to="127.0.0.1" xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/stream\" version="1.0">';
            //ԭ���Ǵ���һ���ַ�����Ϊ ejabberd-19.08-windows ���ϸ񣬶�������Ҳ��Ҫ��ȷ��
            first_login := '<stream:stream to="' + gXmppHost+ '" xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" version="1.0">';

//ok  ejabberd-19.08-windows Ҳ��
//      socketplus.SendBuf(gSo, '<stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" version="1.0" to="'+
//      gXmppHost +
//      '">'); //�����ǹؼ�


            xmpp_atBind := true;
            //��¼�ɹ���Ҫ����һ������
            //[self send_string: first_login];
            //socketplus.SendBuf(gSo, first_login);
            xmpp_send_string(first_login);
            //�Է�Ӧ�û�Ӧʲô? ��ʱ��Ϊ�� "<bind" ��,��ʾ��������¼�ɹ���������� bind
        end;
    
    end;

    //2019//����� bind, session, presence ���������Ǽ��� openfire ������ʱ����Ҫ���ϵģ����� xmppmini �����������Ǳ����
    //�Ժ�� openfire ������Ҳ�п��ܻ���Ҫ����ļ������ĿǰΪ���� openfire_4_1_4

    //--------------------------------------
    //��¼�ɹ����ٷ��� stream:stream ��Ϳ��Եȴ����� bind ��
    //####server��Ӧ������֧�ֵ�features
    //####client����resource bind
    //�ο� https://blog.csdn.net/lixiaowei16/article/details/48573839
    
    //���� bind ��,�ж���жϼ�����ͳ�ȥ
    if (xmpp_atBind = true) then begin

        //���� ejabberd-19.08-windows  'stream:stream xmlns:stream' ����һ����Ҫһ���
        //if (FindStr('stream:stream xmlns:stream', s)) and (FindStr('urn:ietf:params:xml:ns:xmpp-bind', s) ) then begin //������ȷ���� bind ����
        if (FindStr('stream:stream', s)) and (FindStr('xmlns:stream', s)) and (FindStr('urn:ietf:params:xml:ns:xmpp-bind', s) ) then begin //������ȷ���� bind ����

            AddLog('������ȷ���� bind ����');
            clearRecvBuf(); ////��ս��ջ���
            
            //self.isLoginOk = true;
            
            //####client����resource bind
            //NSString * first_login = @"<stream:stream to=\"117.169.20.236\" xmlns=\"jabber:client\" xmlns:stream=\"http://etherx.jabber.org/streams\" version=\"1.0\">";
            resource_bind := '<stream:stream to="127.0.0.1" xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" version="1.0">';
            
            xmpp_xmpp_id := xmpp_xmpp_id + 1;
            s_id := IntToStr(xmpp_xmpp_id);
            
            resource_bind :=
                             //@"<iq type=\"set\" id=\"bind_1\">", //����� id �� spark ��һֱ�ۼ�,���Բ����ö����,һֱ�ۼӾͿ�����
                             '<iq type="set" id="' +  s_id + '">' + //����� id �� spark ��һֱ�ۼ�,���Բ����ö����,һֱ�ۼӾͿ�����
                             '<bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">' +
                             //@"<resource>Psi+</resource>",
                             '<resource>ios</resource>' +
                             '</bind>' +
                             '</iq>' +
                             '';
            
            xmpp_atBind := true;
            //��¼�ɹ���Ҫ����һ������
            AddLog('resource_bind: ' + resource_bind);
            xmpp_send_string(resource_bind);
            //�Է�Ӧ�û�Ӧʲô? ��ʱ��Ϊ�� "<bind" ��,��ʾ��������¼�ɹ���������� bind
        end;//if 2
        
        //bind ����Ļ�Ӧ
        if (FindStr('result' ,s))and(FindStr('urn:ietf:params:xml:ns:xmpp-bind', s)) then begin

            AddLog('��������Ӧ bind ����');
            clearRecvBuf(); ////��ս��ջ���
            
            //<jid>t1@127.0.0.1/ios</jid></bind></iq>
            if (FindStr('</bind></iq>', s)) then begin //�ɹ�,����ȡ����������� jid ��

                //self.xmpp_jid = [Functions get_value:s b_sp1:@"<jid>" e_sp1:@"</jid></bind></iq>"];
                ////xmpp_xmpp_jid = [Functions get_value:s b_sp1:@"<jid>" e_sp1:@"</jid></bind></iq>"];
                xmpp_xmpp_jid := get_value(s, '<jid>',  '</jid></bind></iq>');
                AddLog('xmpp_jid:' + xmpp_xmpp_jid);

                //gXmppFullJid Ŀǰ��ʵ�Ǻ� xmpp_xmpp_jid ��ͬ��
                gXmppFullJid := Trim(xmpp_xmpp_jid);

                //-----------------------
                //bind �ɹ���Ϳ��� client����session //�������� session ��Ŀ����ʲô? �ƺ����沢û���õ� session �Ķ���
                xmpp_atBind := false;
                xmpp_atSession := true;
                
                xmpp_xmpp_id := xmpp_xmpp_id + 1;
                s_id := IntToStr(xmpp_xmpp_id);
                
                //<iq id="48mz5-1" type="set"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>
                ss :=
                                '<iq id="' +
                                 s_id +
                                '" type="set"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' +
                                '</iq>' +
                                '';
//ok
//ss := '<iq id="82imm-1" type="set">' +
//'<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' +
//'</iq>' ;

                
                AddLog('ss:' + ss);
                xmpp_send_string( ss);
            end;//if 3

        end;//if 2
        
    end;//if 1

    //--------------------------------------
    //���� atSession ��
    if (xmpp_atSession = true) then begin

        //��֣�û�����������Ϣ openfire �ǲ��ᷢ�ͶԻ���Ϣ������
        //(*
        if (FindStr('result', s)) then begin
            
            AddLog('��������Ӧ session ����');
            clearRecvBuf(); //��ս��ջ���
            
            //self.isLoginOk = true;
            
            //<presence id="48mz5-10"><status>����</status><priority>1</priority></presence>
            
            xmpp_xmpp_id := xmpp_xmpp_id + 1;
            s_id := IntToStr(xmpp_xmpp_id);
            
            //����� spark �Ļ�Ӧ,psi �Ļ�Ӧ��ʵ��û������
            //openfire ���ԣ��� ejabberd-19.08-windows һ��Ҫת���� utf8 �����Ի�������Ӣ��״̬����
            //����Ҫ�������ע�Ͳ��ֵĽ���
            //s_presence := '<presence id="' + s_id + '"><status>����</status><priority>1</priority></presence>'; //no ejb...
            ////s_presence := '<presence id="' + s_id + '"><status>' + AnsiToUtf8('����') + '</status><priority>1</priority></presence>'; //ok ejb..
            s_presence := '<presence id="' + s_id + '"><status>' + AnsiToUtf8('online') + '</status><priority>1</priority></presence>'; //ok ejb..

            //self.atBind = true;
            xmpp_atSession := false;
            //��¼�ɹ���Ҫ����һ������
            xmpp_send_string(s_presence);
            //�Է�Ӧ�û�Ӧʲô?
        end;//if 2
        //*)
        
    end;//if 1


end;

//presence - ����״̬ //���� https://www.cnblogs.com/hellowzd/p/4152176.html
//
//����״̬��Ϣ������һ������״̬��presence�����С���� type ����ʡ�ԣ���ô XMPP �ͻ���Ӧ�ó���ٶ��û������ҿ��á�����type ������Ϊ unavailable�������ض��� pubsub ��ֵ��subscribe��subscribed��unsubscribe �� unsubscribed����Ҳ�����������һ���û�������״̬��Ϣ��һ�������̽�롣
//
//һ������״̬�ڿ��԰���������Ԫ�أ�
//
//show��һ�������ɶ���ֵ����ʾҪ��ʾ������״̬���������������� away����ʱ�뿪����chat������������Ȥ��������dnd��������ţ����� xa����ʱ���뿪����
//status��һ���ɶ��� show ֵ����ֵΪ�û��ɶ�����ַ�����
//priority��һ��λ�� -128 �� 127 ֮���ֵ��������Ϣ·�ɵ��û�������˳�����ֵΪ�������û�����Ϣ����������
//
//���磬�嵥 6 �е� boreduser@somewhere �����������������������Ը��
//
//
//�嵥 6. ��������״̬֪ͨ
//
//<presence xml:lang="en">
//<show>chat</show>
//<status>Bored out of my mind</status>
//<priority>1</priority>
//</presence>
//
//ע�� from ���Դ˴�ʡ�ԡ�
//
//��һ���û� friendlyuser@somewhereelse ����ͨ������ �嵥 7 �еĽ���̽�� boreduser@somewhere ��״̬��
//
//�嵥 7. ̽���û�״̬
//
//<presence type="probe" from="friendlyuser@somewhereelse" to="boreduser@somewhere"/>
//Boreduser@somewhere's server would then respond with a tailored presence response:
//<presence xml:lang="en" from="boreduser@somewhere" to="friendlyuser@somewhereelse">
//<show>chat</show>
//<status>Bored out of my mind</status>
//<priority>1</priority>
//</presence>
//
//��Щ����״ֵ̬Դ�� ������-���ˡ� ��Ϣ���������show Ԫ�ص�ֵ �� ͨ������ȷ�����������û���ʾ��״̬ͼ�� �� ������Ӧ�ó���֮�����ʹ�����ڻ��������״ֵ̬���ܻ���΢���������ҵ�����֮�أ����磬Google Talk��һ�� XMPP ��������е��û�״̬�ֶεĸ��Ŀ��Ա�����Ϊ Google Buzz �е�΢����Ŀ��
//��һ�ֿ����Ծ��ǽ�״ֵ̬����ÿ�û�Ӧ�ó���״̬���ݵ�Я���ߡ����ܴ˹淶��״̬����Ϊ�ɶ�����û��ʲô�ܹ���ֹ��������洢�����ַ�������������Ҫ�󡣶���ĳЩӦ�ó�����ԣ������Բ��ǿɶ��ģ����ߣ�������Я��΢��ʽ��̬�����ݸ��ء�
//������Ϊһ�� XMPP ʵ��ӵ�е�ÿ����Դ������������״̬��Ϣ���Ա���ʺͽ������ӵ�һ��Ӧ�ó����еĵ����û������й��ߺ������ĵ�����ֻ��һ���û��ʻ���ÿ����Դ�����Ա�����һ�����������ȼ���XMPP �����������ȳ��Խ���Ϣ���ݸ����ȼ��ϸߵ���Դ��



end.

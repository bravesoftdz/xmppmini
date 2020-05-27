unit xmppmini_gethost;

//xmppmini �淶��� xmpp ���ӵ�ַ��ʵ��

interface

uses
  {}inifiles,{}Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, uFormVSkin, pngextra_buttonEx, ExtCtrls, pngimage,
  base64,Des, ShellAPI, 
  xmldom, XMLIntf, msxmldom, XMLDoc, Sockets, WinSock,
  uImagePanel, uColorBorderEdit, pngcheckbox, uColorCheckBox, uTHttpThread,
  uTCLQHttpThreadControl;

function GetXmppMiniHost(host:string):Boolean;
//�����ļ� http://127.0.0.1:8888/html/xmppmini.txt  ����Ϊ�� newbt ��ר�÷�����
function CheckXmppMiniHost(host:string):Boolean;

var
  gXmppMiniHost:TStringList = nil;

  gXmppMini_web_url_login:string;
  gXmppMini_web_url_his:string;
  gXmppMini_web_url_his_peer:string;
  gXmppMini_web_url_user_admin:string; //�û�������Ϣ�����ҳ��
  gXmppMini_web_url_upload_image:string; //����ͼƬ�ϴ�ҳ��

implementation

uses form_pass1, xmMain, uConfig;

var
  gGetXmppMiniHost_count:Integer = 0; //��ȡ�˶��ٴΣ����Ƕ�����Ϊ��

procedure GetXmppMiniHost_OnOK(const out1:string;succeed1:boolean);
var
  server_dyn:Integer;
  host:string;
begin

  gXmppMiniHost.Text := out1;

  if True = succeed1  then
  begin
    gXmppMini_web_url_login := Trim(gXmppMiniHost.Values['web_url_login']); //��ʷ��ȡ����Ϣ
    gXmppMini_web_url_his := Trim(gXmppMiniHost.Values['web_url_his']); //��ʷ��ȡ����Ϣ
    gXmppMini_web_url_his_peer := Trim(gXmppMiniHost.Values['web_url_his_peer']); //��ʷ��ȡ����Ϣ
    gXmppMini_web_url_user_admin := Trim(gXmppMiniHost.Values['web_url_user_admin']); //
    gXmppMini_web_url_upload_image := Trim(gXmppMiniHost.Values['web_url_upload_image']); //

    //2020 �Ƿ��ط�
    server_dyn := StrToIntDef(Trim(gXmppMiniHost.Values['server_dyn']), 0); //����Ƕ�̬���������ط�
    host := Trim(gXmppMiniHost.Values['host']);
    if (1 = server_dyn) then
    if gGetXmppMiniHost_count<2 then
    begin
      GetXmppMiniHost(host);
      Exit; //��Ҫ���ߵ�����ȥ������
    end;

  end
  else //û��ȡ�õĻ�����Ĭ�� xmppmini ��������
  begin
    gXmppMini_web_url_login := 'http://' + GUserHost + ':8888/mail/login.php'; //��¼�ĵ�ַ
    gXmppMini_web_url_his := 'http://' + GUserHost + ':8888/mail/login.php?url=user_xmpp_his.php'; //��ʷ��ȡ����Ϣ
    //gXmppMini_web_url_his_peer := 'http://' + GUserHost + ':8888/mail/login.php?url=user_xmpp_his.php?action=peer'; //��ʷ��ȡ����Ϣ
    gXmppMini_web_url_his_peer := 'http://' + GUserHost + ':8888/mail/login.php?url=user_xmpp_his.php%3Faction=peer'; //��ʷ��ȡ����Ϣ//�����е� [?] Ҫʹ�� httpencode �� [%3F]

    //----
    gXmppMini_web_url_login := 'http://' + GUserHost + ':8888/mail/login.php'; //��¼�ĵ�ַ
    gXmppMini_web_url_his := 'http://' + GUserHost + ':8888/mail/user_xmpp_his.php'; //��ʷ��ȡ����Ϣ
    //gXmppMini_web_url_his_peer := 'http://' + GUserHost + ':8888/mail/login.php?url=user_xmpp_his.php?action=peer'; //��ʷ��ȡ����Ϣ
    gXmppMini_web_url_his_peer := 'http://' + GUserHost + ':8888/mail/user_xmpp_his.php?action=peer'; //��ʷ��ȡ����Ϣ//�����е� [?] Ҫʹ�� httpencode �� [%3F]

    //gXmppMini_web_url_user_admin := 'http://' + GUserHost + ':8888/html/user_admin.html?baseurl=http://192.168.0.112:8888';
    gXmppMini_web_url_user_admin := 'http://' + GUserHost + ':8888/html/user_admin.html?baseurl=http://' + GUserHost + ':8888';

    gXmppMini_web_url_upload_image := 'http://' + GUserHost + ':8888/html/upload_image.html'; //
  end;

  //ShowMessage(out1);
  Form_pass.StartLogin;
end;


//�ļ� http://127.0.0.1:8888/html/xmppmini.txt ���� 'xmppmini'  ����Ϊ�� newbt ��ר�÷�����
procedure CheckXmppMiniHost_OnOK(const out1:string;succeed1:boolean);
begin
  if Pos('xmppmini', out1)>0 then
  begin
    GServerIsXmppMini := True;
  end
  else
  begin
    GServerIsXmppMini := False;
  end;    

  frmMain.ShowUI_xmppmini(GServerIsXmppMini);
end;



function GetXmppMiniHost(host:string):Boolean;
var
  http:TCLQHttpThreadControl;
begin
  Result := False;

  gGetXmppMiniHost_count := gGetXmppMiniHost_count + 1;

  if gXmppMiniHost = nil then gXmppMiniHost := TStringList.Create;
  gXmppMiniHost.Clear;

  gXmppMiniHost.Values['host'] := host;

  //----
  http:=TCLQHttpThreadControl.Create(nil);

  //http.post_url := 'http://' + GUserHost + '/xmppmini.txt';
  http.post_url := 'http://' + host + '/xmppmini.txt';  //��һ�ε��ļ����ǹ̶���
  if (gGetXmppMiniHost_count > 1) then http.post_url := host; //�ڶ��μ�֮����ļ����Ƕ�̬��

  http.is_get := True;

  http.on_ok2 := GetXmppMiniHost_OnOK;

  http.execute;

  //http.Free;

end;

//�����ļ� http://127.0.0.1:8888/html/xmppmini.txt  ����Ϊ�� newbt ��ר�÷�����
function CheckXmppMiniHost(host:string):Boolean;
var
  http:TCLQHttpThreadControl;
begin
  Result := False;

  //ע�⣬�����������������Щ����
  //gGetXmppMiniHost_count := gGetXmppMiniHost_count + 1;

  //if gXmppMiniHost = nil then gXmppMiniHost := TStringList.Create;
  //gXmppMiniHost.Clear;

  //gXmppMiniHost.Values['host'] := host;

  //----
  http:=TCLQHttpThreadControl.Create(nil);

  //http.post_url := 'http://' + GUserHost + '/xmppmini.txt';
  http.post_url := 'http://' + host + ':8888/html/xmppmini.txt';

  http.is_get := True;

  http.on_ok2 := CheckXmppMiniHost_OnOK;

  http.execute;

  //http.Free;

end;

end.

set define off
set verify off
set serveroutput on size 1000000
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

--application/set_environment
prompt Seed and Publish application for all languages
begin
  dbms_output.put_line('setting the current schema to APEX_040000');
  execute immediate 'alter session set current_schema = APEX_040000';
end;
/

prompt Set Credentials...
begin
-- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040000 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id => nvl(wwv_flow_application_install.get_workspace_id,114400445500724));
end;
/

prompt ..running seed and publish
declare
  l_sgid number := 114400445500724;
  l_primary_language_flow_id number := 100;
begin
  for c in (
            select translation_flow_id, translation_flow_language_code
              from wwv_flow_language_map
             where security_group_id = l_sgid
               and primary_language_flow_id = l_primary_language_flow_id
             order by 1
           )
 loop
   -- set security group ID
   wwv_flow_security.g_security_group_id := l_sgid;
   
   wwv_flow_translation_utilities.seed_and_publish
   (
     p_from_flow_id       => l_primary_language_flow_id,
     p_language           => c.translation_flow_language_code,
     p_insert_only        => 'NO',
     p_translated_flow_id => c.translation_flow_id,
     p_security_group_id  => l_sgid
   );
   commit;
 end loop;

end;
/
set verify on
set feedback on
prompt ..Completed successfully

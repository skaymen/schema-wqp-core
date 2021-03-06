create or replace package body log_helper as

    function add_log(p_origin        in web_service_log.origin%type,
                     p_call_type     in web_service_log.call_type%type,
                     p_endpoint      in web_service_log.endpoint%type,
                     p_query_string  in web_service_log.query_string%type,
                     p_post_data     in web_service_log.post_data%type,
                     p_user_agent    in web_service_log.user_agent%type)
        return number
     is
        pragma autonomous_transaction;
        rtn number;
    begin
        insert into web_service_log (origin, call_type, endpoint, query_string, post_data, user_agent)
        values (p_origin, p_call_type, p_endpoint, p_query_string, p_post_data, p_user_agent)
        returning web_service_log_id into rtn;
        commit;
        return rtn;
    end add_log;

    procedure log_head_complete(p_web_service_log_id  in web_service_log.web_service_log_id%type,
                                p_total_rows_expected in web_service_log.total_rows_expected%type,
                                p_data_store_counts   in web_service_log.data_store_counts%type)
    is
        pragma autonomous_transaction;
    begin
        update web_service_log
           set head_sent_utc = sys_extract_utc(systimestamp),
               total_rows_expected = p_total_rows_expected,
               data_store_counts = p_data_store_counts
         where web_service_log_id = p_web_service_log_id;
        commit;
    end log_head_complete;

    procedure log_first_row(p_web_service_log_id in web_service_log.web_service_log_id%type)
    is
        pragma autonomous_transaction;
    begin
        update web_service_log
           set first_row_sent_utc = sys_extract_utc(systimestamp)
         where web_service_log_id = p_web_service_log_id;
        commit;
    end log_first_row;

    procedure log_request_complete(p_web_service_log_id in web_service_log.web_service_log_id%type,
                                   p_http_status_code   in web_service_log.http_status_code%type,
                                   p_download_details   in web_service_log.download_details%type)
    is
        pragma autonomous_transaction;
    begin
        update web_service_log
           set request_completed_utc = sys_extract_utc(systimestamp),
               http_status_code = p_http_status_code,
               download_details = p_download_details
         where web_service_log_id = p_web_service_log_id;
        commit;
    end log_request_complete;

end log_helper;

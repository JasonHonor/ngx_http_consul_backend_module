#include <ndk.h>
#include <libunwind.h>

static ngx_int_t
ngx_http_consul_backend(ngx_http_request_t *r, ngx_str_t *val, ngx_http_variable_value_t *v,void *cfg);

//define filter method.  ndk_set_var_data_code_t
static ndk_set_var_t
ngx_http_consul_backend_filter = {
  NDK_SET_VAR_VALUE_DATA,
  (void *) ngx_http_consul_backend,
  2,
  NULL
};

//define detective, allow multiple, The entry point.
/*
struct ngx_command_s {
    ngx_str_t             name;
    ngx_uint_t            type;
    char               *(*set)(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
    ngx_uint_t            conf;
    ngx_uint_t            offset;
    void                 *post;
};
*/
static ngx_command_t
ngx_http_consul_backend_commands[] = {
  {
    ngx_string("consul"),
    NGX_HTTP_LOC_CONF|NGX_CONF_TAKE2,
    ndk_set_var_value,
    0,
    0,
    &ngx_http_consul_backend_filter
  },
  ngx_null_command
};

static ngx_http_module_t
ngx_http_consul_backend_module_ctx = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };

ngx_module_t ngx_http_consul_backend_module = {
  NGX_MODULE_V1,
  &ngx_http_consul_backend_module_ctx, /* module context */
  ngx_http_consul_backend_commands,    /* module directives */
  NGX_HTTP_MODULE,                     /* module type */
  NULL,                                /* init master */
  NULL,                                /* init module */
  NULL,                                /* init process */
  NULL,                                /* init thread */
  NULL,                                /* exit thread */
  NULL,                                /* exit process */
  NULL,                                /* exit master */
  NGX_MODULE_V1_PADDING
};

void my_backtrace(ngx_log_t *logger)
{
    void *buffer[100] = { NULL };
    char **trace = NULL;

    int size = backtrace(buffer, 100);
    trace = backtrace_symbols(buffer, size);
    if (NULL == trace) {
        return;
    }
    int i=0;
    for (i = 0; i < size; ++i) {
        ngx_log_error(NGX_LOG_DEBUG,logger,"%s\n", trace[i]);
    }
    free(trace);
    ngx_log_error(NGX_LOG_ERR,logger,0,"----------done----------\n");
}

#if 0
void do_backtrace(ngx_log_t *logger) 
{
 
    unw_cursor_t    cursor;
 
    unw_context_t   context;
 
    unw_getcontext(&context);
 
    unw_init_local(&cursor, &context);
 
    while (unw_step(&cursor) > 0) {
 
        unw_word_t  offset, pc;
 
        char        fname[64];
        unw_get_reg(&cursor, UNW_REG_IP, &pc);
 
        fname[0] = '\0';
 
        (void) unw_get_proc_name(&cursor, fname, sizeof(fname), &offset);
 
        ngx_log_error(NGX_LOG_ERR,logger,0, "%p : (%s+0x%x) [%p]\n", pc, fname, offset, pc);
 
    }
}
#endif

static ngx_int_t
ngx_http_consul_backend(ngx_http_request_t *r, ngx_str_t *res, ngx_http_variable_value_t *v,void *cfg) {
  
  void ** loc_cfg = r->loc_conf;
  ngx_http_core_loc_conf_t *clcf = *loc_cfg;
  ngx_str_t loc_name = clcf->name;
  ngx_str_t  url = r->uri;

  //check location.
  if(url.len>loc_name.len)
  {
    #if 0
      char chLocName[64];
      sprintf(chLocName,"%s/",loc_name.data);

      if(ngx_strstr(url.data,chLocName)==NULL)
                return NGX_DECLINED;
    #endif
      
  }else
        if(ngx_strstr(url.data,loc_name.data)<0)
                return NGX_DECLINED; 
  
  void *go_module = dlopen("/nginx/ext/ngx_http_consul_backend_module.so", RTLD_LAZY);
  
  if (!go_module) {
    ngx_log_error(NGX_LOG_ERR, r->connection->log, 0, "go module not found %s","/nginx/ext/ngx_http_consul_backend_module.so");
    return NGX_ERROR;
  }

  u_char* (*fun)(int,u_char *,u_char *,u_char *) = (u_char* (*)(int,u_char *,u_char *,u_char *)) dlsym(go_module, "LookupBackend");
  
  u_char* backend = fun(url.len,url.data,loc_name.data,v->data);

  ngx_str_t ngx_backend = { strlen(backend), backend };

  res->data = ngx_palloc(r->pool, ngx_backend.len);
  
  if (res->data == NULL) {
    return NGX_ERROR;
  }

  ngx_memcpy(res->data, ngx_backend.data, ngx_backend.len);

  res->len = ngx_backend.len;

  ngx_log_error(NGX_LOG_DEBUG, r->connection->log, 0, "url=%s upstream=%s",url.data,res->data);

  return NGX_OK;
}

-- This is types for NetBSD and rump kernel, which are the same bar names.

local function init(rump)

local ffi = require "ffi"

local abi = require "syscall.abi"

require "syscall.ffitypes-common"

local cdef

if rump then
  cdef = ffi.cdef
else
  cdef = function(s)
    s = string.gsub(s, "_netbsd_", "") -- no netbsd types
    ffi.cdef(s)
  end
end

-- TODO note iovec can probably be shared despite very minor type difference

cdef [[
typedef uint32_t _netbsd_mode_t;
typedef uint8_t _netbsd_sa_family_t;
typedef uint64_t _netbsd_dev_t;
typedef uint32_t _netbsd_nlink_t;
typedef uint64_t _netbsd_ino_t;
typedef int64_t _netbsd_time_t;
typedef int64_t _netbsd_daddr_t;
typedef uint64_t _netbsd_blkcnt_t;
typedef uint32_t _netbsd_blksize_t;
typedef int32_t _netbsd_clockid_t;
typedef int _netbsd_ssize_t;
typedef unsigned int _netbsd_size_t;
typedef unsigned long _netbsd_clock_t;
typedef unsigned int _netbsd_socklen_t;

/* these need to be filled in/fixed */
/*
_netbsd_fd_set
*/

struct _netbsd_iovec {
  void *iov_base;
  _netbsd_size_t iov_len;
};
struct _netbsd_timespec {
  _netbsd_time_t tv_sec;
  long   tv_nsec;
};
typedef struct {
  uint32_t      val[4]; // note renamed to match Linux
} _netbsd_sigset_t;
struct _netbsd_sockaddr {
  uint8_t       sa_len;
  _netbsd_sa_family_t   sa_family;
  char          sa_data[14];
};
struct _netbsd_sockaddr_storage {
  uint8_t       ss_len;
  _netbsd_sa_family_t   ss_family;
  char          __ss_pad1[6];
  int64_t       __ss_align;
  char          __ss_pad2[128 - 2 - 8 - 6];
};
struct _netbsd_sockaddr_in {
  uint8_t         sin_len;
  _netbsd_sa_family_t     sin_family;
  in_port_t       sin_port;
  struct in_addr  sin_addr;
  int8_t          sin_zero[8];
};
struct _netbsd_sockaddr_in6 {
  uint8_t         sin6_len;
  _netbsd_sa_family_t     sin6_family;
  in_port_t       sin6_port;
  uint32_t        sin6_flowinfo;
  struct in6_addr sin6_addr;
  uint32_t        sin6_scope_id;
};
struct _netbsd_sockaddr_un {
  uint8_t         sun_len;
  _netbsd_sa_family_t     sun_family;
  char            sun_path[104];
};
struct _netbsd_msghdr {
  void            *msg_name;
  _netbsd_socklen_t       msg_namelen;
  struct _netbsd_iovec    *msg_iov;
  int             msg_iovlen;
  void            *msg_control;
  _netbsd_socklen_t       msg_controllen;
  int             msg_flags;
};
struct _netbsd_stat {
  _netbsd_dev_t     st_dev;
  _netbsd_mode_t    st_mode;
  _netbsd_ino_t     st_ino;
  _netbsd_nlink_t   st_nlink;
  uid_t     st_uid;
  gid_t     st_gid;
  _netbsd_dev_t     st_rdev;
  struct    _netbsd_timespec st_atimespec;
  struct    _netbsd_timespec st_mtimespec;
  struct    _netbsd_timespec st_ctimespec;
  struct    _netbsd_timespec st_birthtimespec;
  off_t     st_size;
  _netbsd_blkcnt_t  st_blocks;
  _netbsd_blksize_t st_blksize;
  uint32_t  st_flags;
  uint32_t  st_gen;
  uint32_t  st_spare[2];
};
typedef union _netbsd_sigval {
  int     sival_int;
  void    *sival_ptr;
} _netbsd_sigval_t;
]]

if abi.abi64 then
cdef [[
struct _ksiginfo {
  int     _signo;
  int     _code;
  int     _errno;
  int     _pad; /* only on LP64 */
  union {
    struct {
      pid_t   _pid;
      uid_t   _uid;
      _netbsd_sigval_t        _value;
    } _rt;
    struct {
      pid_t   _pid;
      uid_t   _uid;
      int     _status;
      _netbsd_clock_t _utime;
      _netbsd_clock_t _stime;
    } _child;
    struct {
      void   *_addr;
      int     _trap;
    } _fault;
    struct {
      long    _band;
      int     _fd;
    } _poll;
  } _reason;
};
]]
else
cdef [[
struct _ksiginfo {
  int     _signo;
  int     _code;
  int     _errno;
  union {
    struct {
      pid_t   _pid;
      uid_t   _uid;
      _netbsd_sigval_t        _value;
    } _rt;
    struct {
      pid_t   _pid;
      uid_t   _uid;
      int     _status;
      _netbsd_clock_t _utime;
      _netbsd_clock_t _stime;
    } _child;
    struct {
      void   *_addr;
      int     _trap;
    } _fault;
    struct {
      long    _band;
      int     _fd;
    } _poll;
  } _reason;
};
]]
end

cdef [[
typedef union _netbsd_siginfo {
  char    si_pad[128];    /* Total size; for future expansion */
  struct _ksiginfo _info;
} _netbsd_siginfo_t;
struct _netbsd_sigaction {
  union {
    void (*sa_handler)(int);
    void (*sa_sigaction)(int, _netbsd_siginfo_t *, void *);
  } sa_handler; // renamed as in Linux definition
  _netbsd_sigset_t sa_mask;
  int sa_flags;
};
]]

end

return {init = init}

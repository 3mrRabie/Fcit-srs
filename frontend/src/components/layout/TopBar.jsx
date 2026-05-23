/* ═══════════════════════════════════════════════════════════════════════════
   TopBar — Fixed top header with search, notifications, user menu
   ═══════════════════════════════════════════════════════════════════════════ */
import React, { useState, useRef, useEffect, useCallback } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { PAGE_TITLES } from '../../utils/constants';
import { getInitials, ROLE_AR } from '../../utils/helpers';
import { Bell, Search, Menu, Lock, LogOut, ChevronDown } from 'lucide-react';
import styles from './layout.module.css';

export default function TopBar({ unread, onMobileMenuToggle }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const [showNotif, setShowNotif] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const notifRef = useRef(null);
  const profileRef = useRef(null);

  // Find current page title
  const title = Object.entries(PAGE_TITLES)
    .find(([k]) => location.pathname.startsWith(k))?.[1] || 'UniSmart';

  const initials = getInitials(user);

  // Close dropdowns on outside click
  useEffect(() => {
    const handler = (e) => {
      if (notifRef.current && !notifRef.current.contains(e.target)) setShowNotif(false);
      if (profileRef.current && !profileRef.current.contains(e.target)) setShowProfile(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const handleLogout = () => {
    logout();
    navigate('/login');
    setShowProfile(false);
  };

  // Role-aware search: navigates to the right page with a search query
  const executeSearch = useCallback(() => {
    const q = searchQuery.trim();
    if (!q) return;
    const role = user?.role;
    if (role === 'student') {
      navigate(`/student/courses?search=${encodeURIComponent(q)}`);
    } else if (role === 'doctor') {
      navigate(`/doctor/courses?search=${encodeURIComponent(q)}`);
    } else if (role === 'admin') {
      navigate(`/admin/students?search=${encodeURIComponent(q)}`);
    }
    setSearchQuery('');
  }, [searchQuery, user, navigate]);

  const handleSearchKeyDown = (e) => {
    if (e.key === 'Enter') {
      executeSearch();
    }
  };

  return (
    <header className={styles.topbar} dir="rtl">
      {/* Mobile menu button */}
      <button
        className={styles.mobileMenuBtn}
        onClick={onMobileMenuToggle}
        aria-label="القائمة"
      >
        <Menu size={20} />
      </button>


      {/* Page title */}
      <div className={styles.topbarTitle}>
        <div className={styles.topbarTitleMain}>{title}</div>
      </div>

      {/* Spacer */}
      <div style={{ flex: 1 }} />

      {/* Search */}
      <div className={styles.topbarSearch}>
        <input
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          onKeyDown={handleSearchKeyDown}
          placeholder="بحث سريع... (Enter للبحث)"
          className={styles.topbarSearchInput}
          aria-label="بحث سريع"
        />
        <Search size={14} className={styles.topbarSearchIcon} onClick={executeSearch} style={{ cursor: 'pointer' }} />
      </div>

      {/* Notifications */}
      <div ref={notifRef} className={styles.topbarDropdownWrap}>
        <button
          className={styles.topbarIconBtn}
          onClick={() => { setShowNotif(p => !p); setShowProfile(false); }}
          aria-label={`الإشعارات ${unread > 0 ? `(${unread} غير مقروءة)` : ''}`}
        >
          <Bell size={18} />
          {unread > 0 && (
            <span className={styles.notifBadge}>
              {unread > 9 ? '9+' : unread}
            </span>
          )}
        </button>
        {showNotif && (
          <div className={styles.dropdown}>
            <div className={styles.dropdownHeader}>
              <span className={styles.dropdownTitle}>الإشعارات</span>
              <span className={styles.dropdownSub}>{unread} غير مقروءة</span>
            </div>
            <div className={styles.dropdownBody}>
              <button
                className={`${styles.dropdownAction}`}
                onClick={() => {
                  setShowNotif(false);
                  navigate(`/${user?.role}/notifications`);
                }}
              >
                عرض كل الإشعارات
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Profile menu */}
      <div ref={profileRef} className={styles.topbarDropdownWrap}>
        <button
          className={styles.topbarProfileBtn}
          onClick={() => { setShowProfile(p => !p); setShowNotif(false); }}
          aria-label="قائمة المستخدم"
        >
          <ChevronDown size={12} className={styles.profileChevron} />
          <div className={styles.profileText}>
            <div className={styles.profileName}>{user?.fullNameAr || user?.fullNameEn || 'مستخدم'}</div>
            <div className={styles.profileRole}>{ROLE_AR[user?.role] || user?.role}</div>
          </div>
          <div className={styles.profileAvatar}>{initials}</div>
        </button>

        {showProfile && (
          <div className={styles.dropdown}>
            <div className={styles.dropdownProfileHeader}>
              <div className={styles.dropdownProfileName}>
                {user?.fullNameAr || user?.fullNameEn}
              </div>
              <div className={styles.dropdownProfileEmail}>{user?.email}</div>
            </div>
            <Link
              to="/change-password"
              className={styles.dropdownItem}
              onClick={() => setShowProfile(false)}
            >
              <Lock size={14} />
              <span>تغيير كلمة المرور</span>
            </Link>
            <div className={styles.dropdownDivider} />
            <button className={styles.dropdownItemDanger} onClick={handleLogout}>
              <LogOut size={14} />
              <span>تسجيل الخروج</span>
            </button>
          </div>
        )}
      </div>
    </header>
  );
}

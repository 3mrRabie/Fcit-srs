/* ═══════════════════════════════════════════════════════════════════════════
   Sidebar — Collapsible right sidebar for RTL layout
   ═══════════════════════════════════════════════════════════════════════════ */
import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { NAV_ITEMS } from '../../utils/constants';
import { getInitials, ROLE_AR } from '../../utils/helpers';
import {
  LayoutDashboard, Users, BookOpen, Settings, Calendar,
  ClipboardList, FolderOpen, Building2, Scale, BarChart3,
  Megaphone, Bell, FileText, GraduationCap, LogOut,
} from 'lucide-react';
import styles from './layout.module.css';

const ICON_MAP = {
  LayoutDashboard, Users, BookOpen, Settings, Calendar,
  ClipboardList, FolderOpen, Building2, Scale, BarChart3,
  Megaphone, Bell, FileText, GraduationCap,
};

export default function Sidebar({ mobileOpen, onMobileClose }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const links = NAV_ITEMS.filter(l => l.roles.includes(user?.role));
  const initials = getInitials(user);

  const isActive = (to) => {
    const exactPaths = ['/admin', '/doctor', '/student'];
    return exactPaths.includes(to) ? location.pathname === to : location.pathname.startsWith(to);
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const sidebarClass = [
    styles.sidebar,
    mobileOpen && styles.sidebar_mobileOpen,
  ].filter(Boolean).join(' ');

  return (
    <>
      {/* Mobile backdrop */}
      {mobileOpen && (
        <div
          className={styles.mobileBackdrop}
          onClick={onMobileClose}
          aria-hidden="true"
        />
      )}

      <aside className={sidebarClass} dir="rtl" role="navigation" aria-label="القائمة الرئيسية">


        {/* Logo */}
        <div className={styles.sidebarLogo}>
          <div className={styles.logoIcon}>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <rect x="2" y="2" width="7" height="7" rx="1.5" fill="white" opacity=".95"/>
              <rect x="11" y="2" width="7" height="7" rx="1.5" fill="white" opacity=".5"/>
              <rect x="2" y="11" width="7" height="7" rx="1.5" fill="white" opacity=".5"/>
              <rect x="11" y="11" width="7" height="7" rx="1.5" fill="white" opacity=".95"/>
            </svg>
          </div>
          <div>
            <div className={styles.logoText}>UniSmart</div>
            <div className={styles.logoSub}>نظام إدارة جامعي</div>
          </div>
        </div>

        {/* Navigation links */}
        <nav className={styles.sidebarNav}>
          {links.map(link => {
            const Icon = ICON_MAP[link.icon];
            const active = isActive(link.to);
            return (
              <Link
                key={link.to}
                to={link.to}
                className={`${styles.navLink} ${active ? styles.navLink_active : ''}`}
                onClick={mobileOpen ? onMobileClose : undefined}
              >
                <span className={styles.navIcon}>
                  {Icon ? <Icon size={18} /> : null}
                </span>
                <span>{link.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Bottom section */}
        <div className={styles.sidebarBottom}>
          <div className={styles.userCard}>
            <div className={styles.userAvatar}>{initials}</div>
            <div className={styles.userInfo}>
              <div className={styles.userName}>
                {user?.fullNameAr || user?.fullNameEn || 'مستخدم'}
              </div>
              <div className={styles.userRole}>{ROLE_AR[user?.role] || user?.role}</div>
            </div>
          </div>
          <button
            className={styles.logoutBtn}
            onClick={handleLogout}
          >
            <LogOut size={16} />
            <span>تسجيل الخروج</span>
          </button>
        </div>
      </aside>
    </>
  );
}

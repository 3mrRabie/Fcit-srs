/* ═══════════════════════════════════════════════════════════════════════════
   LoginPage — Auth card with demo credentials
   ═══════════════════════════════════════════════════════════════════════════ */
import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { useAuth } from '../../contexts/AuthContext';
import { ROLE_HOME } from '../../utils/helpers';
import AuthLayout from '../../components/layout/AuthLayout';
import styles from './auth.module.css';

export default function LoginPage() {
  const { login, user, loading: authLoading } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [pw, setPw] = useState('');
  const [busy, setBusy] = useState(false);
  const [showPw, setShowPw] = useState(false);

  useEffect(() => {
    if (!authLoading && user) {
      navigate(ROLE_HOME[user.role] || '/admin', { replace: true });
    }
  }, [user, authLoading, navigate]);

  const DEMOS = [
    { lb: 'مسؤول', email: 'admin@fci.tanta.edu.eg', pw: 'Admin@2026!', c: '#7c3aed', b: 'ADM' },
    { lb: 'دكتور', email: 'dr.ahmed@fci.tanta.edu.eg', pw: 'Doctor@2026!', c: '#0891b2', b: 'DR' },
    { lb: 'طالب', email: 's.2024cs001@fci.tanta.edu.eg', pw: 'Student@2026!', c: '#059669', b: 'STD' },
  ];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setBusy(true);
    try {
      const { user: u } = await login(email, pw);
      toast.success('مرحباً، ' + (u.fullNameAr || u.fullNameEn || 'مستخدم') + '!', { id: 'login-toast', duration: 1500 });
      navigate(u.mustChangePw ? '/change-password' : (ROLE_HOME[u.role] || '/admin'), { replace: true });
    } catch (err) {
      toast.error(err.response?.data?.message || 'بيانات الدخول غير صحيحة');
    } finally {
      setBusy(false);
    }
  };

  return (
    <AuthLayout>
      <h2 className={styles.title}>تسجيل الدخول</h2>
      <form onSubmit={handleSubmit} className={styles.form}>
        <div className={styles.inputWrap}>
          <span className={styles.inputIcon}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
              <polyline points="22,6 12,13 2,6"></polyline>
            </svg>
          </span>
          <input
            type="email"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            autoFocus
            placeholder="البريد الإلكتروني"
            className={styles.authInput}
          />
        </div>
        <div className={styles.inputWrap}>
          <span className={styles.inputIcon}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
              <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
            </svg>
          </span>
          <input
            type={showPw ? 'text' : 'password'}
            value={pw}
            onChange={e => setPw(e.target.value)}
            required
            placeholder="كلمة المرور"
            className={styles.authInput}
          />
          <button
            type="button"
            onClick={() => setShowPw(!showPw)}
            className={styles.eyeBtn}
          >
            {showPw ? (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                <line x1="1" y1="1" x2="23" y2="23"></line>
              </svg>
            ) : (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                <circle cx="12" cy="12" r="3"></circle>
              </svg>
            )}
          </button>
        </div>
        <button type="submit" disabled={busy} className={styles.submitBtn}>
          {busy ? 'جاري…' : 'تسجيل الدخول'}
        </button>
      </form>
      <div className={styles.forgotLink}>
        <Link to="/forgot">نسيت كلمة المرور؟</Link>
      </div>
      <div className={styles.demoSection}>
        <div className={styles.demoTitle}>دخول تجريبي</div>
        <div className={styles.demoGrid}>
          {DEMOS.map(d => (
            <button
              key={d.lb}
              onClick={() => { setEmail(d.email); setPw(d.pw); }}
              className={styles.demoBtn}
              style={{ borderColor: d.c + '33' }}
            >
              <div className={styles.demoBadge} style={{ background: d.c + '18', color: d.c }}>{d.b}</div>
              <div className={styles.demoLabel} style={{ color: d.c }}>{d.lb}</div>
            </button>
          ))}
        </div>
      </div>
    </AuthLayout>
  );
}

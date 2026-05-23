import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import AuthLayout from '../../components/layout/AuthLayout';
import styles from './auth.module.css';

export default function ForgotPage() {
  const [email, setEmail] = useState('');
  const [busy, setBusy] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setBusy(true);
    await new Promise(r => setTimeout(r, 800));
    setSent(true);
    toast.success('إذا كان البريد مسجلاً، ستصل رسالة الاستعادة');
    setBusy(false);
  };

  return (
    <AuthLayout>
      <h2 className={styles.title}>إعادة تعيين كلمة المرور</h2>
      {sent ? (
        <div className={styles.successMsg}>✅ تم الإرسال</div>
      ) : (
        <form onSubmit={handleSubmit} className={styles.form}>
          <div className={styles.inputWrap}>
            <span className={styles.inputIcon}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                <polyline points="22,6 12,13 2,6"></polyline>
              </svg>
            </span>
            <input type="email" value={email} onChange={e => setEmail(e.target.value)}
              required placeholder="البريد الإلكتروني" autoFocus className={styles.authInput} />
          </div>
          <button type="submit" disabled={busy} className={styles.submitBtn}>
            {busy ? 'جاري الإرسال…' : 'إرسال'}
          </button>
        </form>
      )}
      <div className={styles.backLink}>
        <Link to="/login">العودة إلى تسجيل الدخول &rarr;</Link>
      </div>
    </AuthLayout>
  );
}

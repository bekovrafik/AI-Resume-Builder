
import React from 'react';
import { Document, Page, Text, View, StyleSheet, Font, Image } from '@react-pdf/renderer';
import { ResumeData, ResumeTheme } from '../types';

Font.register({
  family: 'Inter',
  fonts: [
    { src: 'https://fonts.gstatic.com/s/inter/v12/UcC73FwrK3iLTeHuS_fvQtMwCp50KnMa1ZL7W0Q5nw.ttf', fontWeight: 400 },
    { src: 'https://fonts.gstatic.com/s/inter/v12/UcC73FwrK3iLTeHuS_fvQtMwCp50KnMa1ZL7W0Q5nw.ttf', fontWeight: 600 },
    { src: 'https://fonts.gstatic.com/s/inter/v12/UcC73FwrK3iLTeHuS_fvQtMwCp50KnMa1ZL7W0Q5nw.ttf', fontWeight: 700 },
  ]
});

Font.register({
  family: 'Playfair Display',
  src: 'https://fonts.gstatic.com/s/playfairdisplay/v30/nuFvD7K6E1n0f-p0M5SPrW-MpYU.ttf',
  fontWeight: 700
});

const getStyles = (theme: ResumeTheme) => {
  const base = {
    page: { padding: 40, backgroundColor: '#FFFFFF', fontFamily: 'Inter' },
    section: { marginBottom: 20 },
    experienceItem: { marginBottom: 15, position: 'relative' as const, paddingLeft: 15 },
    expHeader: { flexDirection: 'row' as const, justifyContent: 'space-between' as const, alignItems: 'baseline' as const, marginBottom: 2 },
    achievement: { fontSize: 9, lineHeight: 1.5, color: '#374151', marginBottom: 3, paddingLeft: 10 },
    bullet: { position: 'absolute' as const, left: 0, top: 3, fontSize: 10, color: '#B45309' },
    skillsGrid: { flexDirection: 'row' as const, flexWrap: 'wrap' as const, gap: 15 },
    skillCategory: { width: '30%' },
    categoryTitle: { fontSize: 8, fontWeight: 700, textTransform: 'uppercase' as const, marginBottom: 4, color: '#9CA3AF', letterSpacing: 0.5 },
    skillBadge: { fontSize: 7.5, backgroundColor: '#F9FAFB', border: '0.2pt solid #E5E7EB', paddingHorizontal: 5, paddingVertical: 2, borderRadius: 2, color: '#4B5563', marginRight: 4, marginBottom: 4 },
    timelineTrack: { position: 'absolute' as const, left: 0, top: 0, bottom: 0, width: 0.5, backgroundColor: '#E5E7EB' },
    timelineNode: { position: 'absolute' as const, left: -2, top: 6, width: 4, height: 4, borderRadius: 2, backgroundColor: '#111827' }
  };

  switch (theme) {
    case "Minimalist":
      return StyleSheet.create({
        ...base,
        page: { ...base.page, paddingHorizontal: 50 },
        header: { textAlign: 'center', marginBottom: 30, alignItems: 'center' },
        avatar: { width: 40, height: 40, borderRadius: 20, marginBottom: 8 },
        name: { fontSize: 20, fontWeight: 300, textTransform: 'uppercase', letterSpacing: 4, marginBottom: 2, color: '#111827' },
        title: { fontSize: 8, fontWeight: 700, textTransform: 'uppercase', letterSpacing: 2, color: '#9CA3AF' },
        sectionTitle: { fontSize: 8.5, fontWeight: 700, textTransform: 'uppercase', color: '#111827', letterSpacing: 1.5, borderBottom: '0.5pt solid #F3F4F6', paddingBottom: 4, marginBottom: 12 },
        company: { fontSize: 10, fontWeight: 700, color: '#111827' },
        period: { fontSize: 8, color: '#9CA3AF' },
        role: { fontSize: 9, color: '#6B7280', marginBottom: 4 },
      } as any);
    case "Creative Nomad":
      return StyleSheet.create({
        ...base,
        page: { ...base.page, backgroundColor: '#FCFAF7', borderLeft: '10pt solid #D4AF37' },
        header: { marginBottom: 25, flexDirection: 'row', gap: 15, alignItems: 'flex-start' },
        avatar: { width: 60, height: 60, borderRadius: 8, border: '1.5pt solid #D4AF37' },
        name: { fontSize: 24, fontWeight: 700, color: '#2C241D' },
        title: { fontSize: 10, color: '#D4AF37', fontWeight: 600, marginTop: 2 },
        sectionTitle: { fontSize: 9, fontWeight: 700, textTransform: 'uppercase', color: '#FFFFFF', backgroundColor: '#2C241D', paddingHorizontal: 6, paddingVertical: 3, marginBottom: 12, width: 'auto' },
        company: { fontSize: 10, fontWeight: 700, color: '#2C241D' },
        period: { fontSize: 7.5, color: '#6B7280', fontWeight: 700 },
        role: { fontSize: 8.5, fontWeight: 700, color: '#D4AF37', fontStyle: 'italic', marginBottom: 4 },
      } as any);
    case "Modernist":
      return StyleSheet.create({
        ...base,
        page: { ...base.page, borderTop: '10pt solid #1E3A8A' },
        header: { marginBottom: 25, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
        name: { fontSize: 22, fontWeight: 700, color: '#1E3A8A' },
        title: { fontSize: 10, color: '#6B7280' },
        sectionTitle: { fontSize: 9, fontWeight: 700, textTransform: 'uppercase', color: '#1E3A8A', borderBottom: '1pt solid #E5E7EB', paddingBottom: 3, marginBottom: 10 },
      } as any);
    case "Silicon Valley":
      return StyleSheet.create({
        ...base,
        page: { ...base.page, backgroundColor: '#000000', color: '#FFFFFF' },
        name: { fontSize: 24, fontWeight: 900, color: '#22C55E' },
        title: { fontSize: 10, color: '#6B7280' },
        sectionTitle: { fontSize: 9, fontWeight: 700, textTransform: 'uppercase', color: '#22C55E', marginBottom: 10 },
        achievement: { ...base.achievement, color: '#D1D5DB' },
        bullet: { ...base.bullet, color: '#22C55E' },
        skillBadge: { ...base.skillBadge, backgroundColor: '#111827', color: '#22C55E', borderColor: '#22C55E' },
      } as any);
    case "Academic":
      return StyleSheet.create({
        ...base,
        header: { textAlign: 'center', marginBottom: 20, borderBottom: '1pt solid #000', paddingBottom: 10 },
        name: { fontSize: 18, fontWeight: 700 },
        title: { fontSize: 10, textTransform: 'uppercase', marginTop: 3 },
        sectionTitle: { fontSize: 10, fontWeight: 700, textTransform: 'uppercase', textAlign: 'center', marginBottom: 10 },
      } as any);
    case "Royal High-End":
      return StyleSheet.create({
        ...base,
        page: { ...base.page, backgroundColor: '#0A0A0A', border: '5pt solid #D4AF37' },
        header: { textAlign: 'center', marginBottom: 30 },
        name: { fontSize: 28, fontWeight: 900, color: '#D4AF37', textTransform: 'uppercase' },
        title: { fontSize: 12, color: '#D4AF37', letterSpacing: 2 },
        sectionTitle: { fontSize: 10, fontWeight: 700, textTransform: 'uppercase', color: '#D4AF37', textAlign: 'center', marginBottom: 15 },
        achievement: { ...base.achievement, color: '#F3F4F6' },
        bullet: { ...base.bullet, color: '#D4AF37' },
      } as any);
    default: // Executive
      return StyleSheet.create({
        ...base,
        page: { ...base.page },
        header: { borderBottom: '1.5pt solid #111827', paddingBottom: 10, marginBottom: 25, flexDirection: 'row', alignItems: 'center', gap: 15 },
        avatar: { width: 50, height: 50, borderRadius: 25, border: '1.5pt solid #111827' },
        name: { fontFamily: 'Playfair Display', fontSize: 28, textTransform: 'uppercase', color: '#111827' },
        title: { fontSize: 12, color: '#4B5563', fontWeight: 500 },
        sectionTitle: { fontSize: 9.5, fontWeight: 700, textTransform: 'uppercase', color: '#111827', letterSpacing: 1, borderBottom: '0.4pt solid #E5E7EB', paddingBottom: 4, marginBottom: 12 },
        company: { fontSize: 11, fontWeight: 700, color: '#111827' },
        period: { fontSize: 9, color: '#6B7280' },
        role: { fontSize: 10, fontWeight: 600, fontStyle: 'italic', color: '#4B5563', marginBottom: 4 },
      } as any);
  }
};

export const ResumePDFDocument = ({ data, theme }: { data: ResumeData, theme: ResumeTheme }) => {
  const styles = getStyles(theme);

  return (
    <Document title={`${data.fullName || 'Career Narrative'} - ${theme} Resume`} author="AI Resume Builder">
      <Page size="A4" style={styles.page}>
        <View style={styles.header}>
          {data.avatarUrl && (
            <Image src={data.avatarUrl} style={styles.avatar} />
          )}
          <View>
            <Text style={styles.name}>{data.fullName || 'Career Architect'}</Text>
            <Text style={styles.title}>{data.targetRole || 'Executive Standard'}</Text>
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Professional Blueprint</Text>
          <Text style={{ fontSize: 9.5, lineHeight: 1.6, color: theme === 'Creative Nomad' || theme === 'Silicon Valley' || theme === 'Royal High-End' ? '#D1D5DB' : '#374151' }}>
            {data.summary || 'Strategic leadership specialist focused on impact.'}
          </Text>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Career Legacy</Text>
          <View>
            {(data.experiences || []).map((exp, i) => (
              <View key={i} style={styles.experienceItem} wrap={false}>
                <View style={styles.timelineTrack} />
                <View style={styles.timelineNode} />
                <View style={styles.expHeader}>
                  <Text style={styles.company}>{exp.company || 'Confidential'}</Text>
                  <Text style={styles.period}>{exp.period || 'Present'}</Text>
                </View>
                <Text style={styles.role}>{exp.role || 'Executive'}</Text>
                {(exp.achievements || []).map((ach, ai) => (
                  <View key={ai} style={{ position: 'relative', marginBottom: 3 }}>
                    <Text style={styles.bullet}>•</Text>
                    <Text style={styles.achievement}>{ach}</Text>
                  </View>
                ))}
              </View>
            ))}
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Strategic Expertise</Text>
          <View style={styles.skillsGrid}>
            {(data.skills || []).map((cat, i) => (
              <View key={i} style={styles.skillCategory}>
                <Text style={styles.categoryTitle}>{cat.category}</Text>
                <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
                  {(cat.skills || []).map((skill, si) => (
                    <Text key={si} style={styles.skillBadge}>{skill}</Text>
                  ))}
                </View>
              </View>
            ))}
          </View>
        </View>

        <View style={{ position: 'absolute', bottom: 20, left: 40, right: 40, borderTop: '0.5pt solid #F3F4F6', paddingTop: 8, flexDirection: 'row', justifyContent: 'space-between' }}>
          <Text style={{ fontSize: 6, color: '#9CA3AF' }}>AI Resume Builder Professional Suite</Text>
          <Text style={{ fontSize: 6, color: '#9CA3AF' }}>Optimized for Institutional Review</Text>
        </View>
      </Page>
    </Document>
  );
};

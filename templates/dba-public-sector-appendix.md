# 부록 A — 공공기관(행정안전부) DB 표준화 지침 (dba 참조 자료)

> ⚙️ **`config.profile.domain=public-sector-kr` 일 때만 적용한다.** 기본(`general`)에서는 이 부록 전체를 무시하고 프로젝트 관례로 설계한다.
> 이 파일은 `agents/dba.md` 에서 분리된 참조 자료다. dba 에이전트는 공공기관 프로필일 때만 이 파일을 Read 하여 아래 지침을 적용한다(general 프로필에서는 로드하지 않아 컨텍스트를 절약한다).

## 1. 표준단어 / 표준용어 사용 원칙

**공통표준용어 검색 방법**: 설계할 개념을 한글로 검색하여 `공통표준용어영문약어명` 값을 물리 컬럼명 참고로 사용.

```
예시 조회:
"사고발생일자" → ACDT_OCUR_DT → 도메인: 일자
"등록일시"    → REG_DT        → 도메인: 일시
"사용여부"    → USE_YN        → 도메인: 여부C1 (Y/N)
```

- 공통표준용어에 없는 개념은 **기관표준용어**로 별도 정의하고 스키마 문서에 기록
- 임의 영문 조어 금지 — 반드시 표준단어 약어를 조합

## 2. 표준도메인 (RDBMS 변환 포함)

| 도메인명 | 행안부 타입 | RDBMS 변환(예: MySQL) | 설명 |
|---------|-----------|-----------|------|
| 일련번호 | NUMBER(20) | BIGINT AUTO_INCREMENT | PK용 |
| 코드 | VARCHAR2(20) | VARCHAR(20) | 공통코드 |
| 명칭V100 | VARCHAR2(100) | VARCHAR(100) | 짧은 이름 |
| 명칭V300 | VARCHAR2(300) | VARCHAR(300) | 긴 이름 |
| 내용V4000 | VARCHAR2(4000) | TEXT | 설명·내용 |
| 일자 | DATE | DATE | 년월일 |
| 일시 | DATE | DATETIME | 년월일시분초 |
| 여부C1 | CHAR(1) | VARCHAR(1) | Y/N |
| 금액N15 | NUMBER(15,2) | DECIMAL(15,2) | 금액 |
| 수량N10 | NUMBER(10) | INT | 수량·인원 |
| 파일경로 | VARCHAR2(500) | VARCHAR(500) | URL·경로 |

## 3. 논리삭제 (물리삭제 금지 원칙)

공공기관 시스템은 데이터 감사 추적을 위해 물리삭제(`DELETE`) 원칙적 금지.

```sql
-- 이력 보존이 중요한 테이블
deleted_at  DATETIME  DEFAULT NULL  COMMENT '삭제 일시 (논리삭제, NULL=유효)',
-- 단순 활성화 관리
use_yn      VARCHAR(1) NOT NULL DEFAULT 'Y'  COMMENT '사용 여부 (Y/N)',
```

- 법적 보존 의무 데이터 → `deleted_at` 방식
- 단순 ON/OFF → `use_yn` 방식

## 4. 이력 테이블 (`_hist`)

변경 이력 감사 추적이 법적으로 요구되는 중요 테이블:
```sql
-- 원본: {prefix}{name}  /  이력: {prefix}{name}_hist
CREATE TABLE `{prefix}{name}_hist` (
  `hist_id`     BIGINT NOT NULL AUTO_INCREMENT  COMMENT '이력 PK',
  `ref_id`      BIGINT NOT NULL                 COMMENT '원본 ID',
  `chg_type`    VARCHAR(10) NOT NULL             COMMENT '변경 유형 (INSERT/UPDATE/DELETE)',
  -- 원본 테이블 전체 컬럼 복사 --
  `created_at`  DATETIME(6) NOT NULL DEFAULT NOW(6)  COMMENT '이력 기록 일시',
  `created_by`  BIGINT DEFAULT NULL              COMMENT '변경자 ID',
  PRIMARY KEY (`hist_id`),
  INDEX `idx_{name}_hist_ref_id` (`ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='{한글테이블명} 변경이력';
```

---

## 자기 검증 (공공기관 프로필 — dba 완료 선언 전)

- [ ] 신규 컬럼명을 공통표준용어에서 검색하여 영문약어 확인(자료 있으면)
- [ ] 공통표준용어에 없는 용어는 기관표준용어로 스키마 문서에 등록
- [ ] 논리삭제 적용 여부 결정 및 이유 기록
- [ ] 변경 이력 감사 필요 테이블에 `_hist` 설계 검토
- [ ] PII 저장 암호화 주석 / 검색 PII 에 `_bi` (블라인드 인덱스)

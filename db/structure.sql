--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: es_co_utf_8; Type: COLLATION; Schema: public; Owner: -
--

CREATE COLLATION es_co_utf_8 (lc_collate = 'es_CO.UTF-8', lc_ctype = 'es_CO.UTF-8');


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: soundexesp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION soundexesp(input text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
DECLARE
	soundex text='';	
	-- para determinar la primera letra
	pri_letra text;
	resto text;
	sustituida text ='';
	-- para quitar adyacentes
	anterior text;
	actual text;
	corregido text;
BEGIN
       -- devolver null si recibi un string en blanco o con espacios en blanco
	IF length(trim(input))= 0 then
		RETURN NULL;
	end IF;
 
 
	-- 1: LIMPIEZA:
		-- pasar a mayuscula, eliminar la letra "H" inicial, los acentos y la enie
		-- 'holá coñó' => 'OLA CONO'
		input=translate(ltrim(trim(upper(input)),'H'),'ÑÁÉÍÓÚÀÈÌÒÙÜ','NAEIOUAEIOUU');
 
		-- eliminar caracteres no alfabéticos (números, símbolos como &,%,",*,!,+, etc.
		input=regexp_replace(input, '[^a-zA-Z]', '', 'g');
 
	-- 2: PRIMERA LETRA ES IMPORTANTE, DEBO ASOCIAR LAS SIMILARES
	--  'vaca' se convierte en 'baca'  y 'zapote' se convierte en 'sapote'
	-- un fenomeno importante es GE y GI se vuelven JE y JI; CA se vuelve KA, etc
	pri_letra =substr(input,1,1);
	resto =substr(input,2);
	CASE 
		when pri_letra IN ('V') then
			sustituida='B';
		when pri_letra IN ('Z','X') then
			sustituida='S';
		when pri_letra IN ('G') AND substr(input,2,1) IN ('E','I') then
			sustituida='J';
		when pri_letra IN('C') AND substr(input,2,1) NOT IN ('H','E','I') then
			sustituida='K';
		else
			sustituida=pri_letra;
 
	end case;
	--corregir el parametro con las consonantes sustituidas:
	input=sustituida || resto;		
 
	-- 3: corregir "letras compuestas" y volverlas una sola
	input=REPLACE(input,'CH','V');
	input=REPLACE(input,'QU','K');
	input=REPLACE(input,'LL','J');
	input=REPLACE(input,'CE','S');
	input=REPLACE(input,'CI','S');
	input=REPLACE(input,'YA','J');
	input=REPLACE(input,'YE','J');
	input=REPLACE(input,'YI','J');
	input=REPLACE(input,'YO','J');
	input=REPLACE(input,'YU','J');
	input=REPLACE(input,'GE','J');
	input=REPLACE(input,'GI','J');
	input=REPLACE(input,'NY','N');
	-- para debug:    --return input;
 
	-- EMPIEZA EL CALCULO DEL SOUNDEX
	-- 4: OBTENER PRIMERA letra
	pri_letra=substr(input,1,1);
 
	-- 5: retener el resto del string
	resto=substr(input,2);
 
	--6: en el resto del string, quitar vocales y vocales fonéticas
	resto=translate(resto,'@AEIOUHWY','@');
 
	--7: convertir las letras foneticamente equivalentes a numeros  (esto hace que B sea equivalente a V, C con S y Z, etc.)
	resto=translate(resto, 'BPFVCGKSXZDTLMNRQJ', '111122222233455677');
	-- así va quedando la cosa
	soundex=pri_letra || resto;
 
	--8: eliminar números iguales adyacentes (A11233 se vuelve A123)
	anterior=substr(soundex,1,1);
	corregido=anterior;
 
	FOR i IN 2 .. length(soundex) LOOP
		actual = substr(soundex, i, 1);
		IF actual <> anterior THEN
			corregido=corregido || actual;
			anterior=actual;			
		END IF;
	END LOOP;
	-- así va la cosa
	soundex=corregido;
 
	-- 9: siempre retornar un string de 4 posiciones
	soundex=rpad(soundex,4,'0');
	soundex=substr(soundex,1,4);		
 
	-- YA ESTUVO
	RETURN soundex;	
END;	
$$;


--
-- Name: actividadoficio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE actividadoficio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE acto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anexo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE anexo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: antecedente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE antecedente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caso_etiqueta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE caso_etiqueta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caso_presponsable_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE caso_presponsable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: caso_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE caso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clase_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clase_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contexto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contexto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departamento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE departamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: escolaridad_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE escolaridad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: estadocivil_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE estadocivil_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: etiqueta_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE etiqueta_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: etnia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE etnia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ffrecuente_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ffrecuente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filiacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE filiacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fotra_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fotra_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: frontera_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE frontera_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grupoper_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grupoper_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: iglesia_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE iglesia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: instanciader_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE instanciader_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intervalo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE intervalo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maternidad_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE maternidad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: municipio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE municipio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pconsolidado_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pconsolidado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: persona_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE persona_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: presponsable_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE presponsable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profesion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profesion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rangoedad_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rangoedad_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regimensalud_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regimensalud_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: region_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE region_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regionsjr_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE regionsjr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sectorsocial_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sectorsocial_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_actividad (
    id integer NOT NULL,
    minutos integer,
    nombre character varying(500),
    objetivo character varying(500),
    proyecto character varying(500),
    resultado character varying(500),
    fecha date,
    observaciones character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    regionsjr_id integer NOT NULL,
    rangoedadac_id integer
);


--
-- Name: sivel2_gen_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_actividad_id_seq OWNED BY sivel2_gen_actividad.id;


--
-- Name: sivel2_gen_actividad_rangoedadac; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_actividad_rangoedadac (
    id integer NOT NULL,
    actividad_id integer,
    rangoedadac_id integer,
    ml integer,
    mr integer,
    fl integer,
    fr integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_actividad_rangoedadac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_actividad_rangoedadac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividad_rangoedadac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_actividad_rangoedadac_id_seq OWNED BY sivel2_gen_actividad_rangoedadac.id;


--
-- Name: sivel2_gen_actividadarea; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_actividadarea (
    id integer NOT NULL,
    nombre character varying(500),
    observaciones character varying(5000),
    fechacreacion date DEFAULT ('now'::text)::date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_actividadarea_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_actividadarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividadarea_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_actividadarea_id_seq OWNED BY sivel2_gen_actividadarea.id;


--
-- Name: sivel2_gen_actividadareas_actividad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_actividadareas_actividad (
    id integer NOT NULL,
    actividad_id integer,
    actividadarea_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_actividadareas_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_actividadareas_actividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_actividadareas_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_actividadareas_actividad_id_seq OWNED BY sivel2_gen_actividadareas_actividad.id;


--
-- Name: sivel2_gen_actividadoficio; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_actividadoficio (
    id integer DEFAULT nextval('actividadoficio_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT actividadoficio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_acto; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_acto (
    id_presponsable integer NOT NULL,
    id_categoria integer NOT NULL,
    id_persona integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('acto_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_actocolectivo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_actocolectivo (
    id_presponsable integer NOT NULL,
    id_categoria integer NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_anexo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_anexo (
    id integer DEFAULT nextval('anexo_seq'::regclass) NOT NULL,
    id_caso integer NOT NULL,
    fecha date NOT NULL,
    descripcion character varying(1500) NOT NULL,
    archivo character varying(255),
    id_ffrecuente integer,
    fechaffrecuente date,
    id_fotra integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    adjunto_file_name character varying(255),
    adjunto_content_type character varying(255),
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_anexoactividad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_anexoactividad (
    id integer NOT NULL,
    actividad_id integer,
    descripcion character varying(1500),
    adjunto_file_name character varying(255),
    adjunto_content_type character varying(255),
    adjunto_file_size integer,
    adjunto_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_anexoactividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_anexoactividad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_anexoactividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_anexoactividad_id_seq OWNED BY sivel2_gen_anexoactividad.id;


--
-- Name: sivel2_gen_antecedente; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_antecedente (
    id integer DEFAULT nextval('antecedente_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT antecedente_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_antecedente_caso; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_antecedente_caso (
    id_antecedente integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_antecedente_comunidad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_antecedente_comunidad (
    id_antecedente integer NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_antecedente_victima; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_antecedente_victima (
    id_antecedente integer NOT NULL,
    id_persona integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_victima integer
);


--
-- Name: sivel2_gen_caso; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso (
    id integer DEFAULT nextval('caso_seq'::regclass) NOT NULL,
    titulo character varying(50),
    fecha date NOT NULL,
    hora character varying(10),
    duracion character varying(10),
    memo text NOT NULL,
    grconfiabilidad character varying(5),
    gresclarecimiento character varying(5),
    grimpunidad character varying(5),
    grinformacion character varying(5),
    bienes text,
    id_intervalo integer DEFAULT 5,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_categoria_presponsable; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_categoria_presponsable (
    id_tviolencia character varying(1) NOT NULL,
    id_supracategoria integer NOT NULL,
    id_categoria integer NOT NULL,
    id_caso integer NOT NULL,
    id_presponsable integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_caso_presponsable integer
);


--
-- Name: sivel2_gen_caso_contexto; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_contexto (
    id_caso integer NOT NULL,
    id_contexto integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_etiqueta; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_etiqueta (
    id_caso integer NOT NULL,
    id_etiqueta integer NOT NULL,
    id_usuario integer NOT NULL,
    fecha date NOT NULL,
    observaciones character varying(5000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('caso_etiqueta_seq'::regclass) NOT NULL
);


--
-- Name: sivel2_gen_caso_ffrecuente; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_ffrecuente (
    fecha date NOT NULL,
    ubicacion character varying(100),
    clasificacion character varying(100),
    ubicacionfisica character varying(100),
    id_ffrecuente integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_fotra; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_fotra (
    id_caso integer NOT NULL,
    id_fotra integer NOT NULL,
    anotacion character varying(200),
    fecha date NOT NULL,
    ubicacionfisica character varying(100),
    tfuente character varying(25),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_frontera; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_frontera (
    id_frontera integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_presponsable; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_presponsable (
    id_caso integer NOT NULL,
    id_presponsable integer NOT NULL,
    tipo integer DEFAULT 0 NOT NULL,
    bloque character varying(50),
    frente character varying(50),
    brigada character varying(50),
    batallon character varying(50),
    division character varying(50),
    otro character varying(500),
    id integer DEFAULT nextval('caso_presponsable_seq'::regclass) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_region; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_region (
    id_region integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_caso_usuario; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_caso_usuario (
    id_usuario integer NOT NULL,
    id_caso integer NOT NULL,
    fechainicio date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_categoria; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_categoria (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    id_supracategoria integer NOT NULL,
    id_tviolencia character varying(1) NOT NULL,
    id_pconsolidado integer,
    contadaen integer,
    tipocat character(1) DEFAULT 'I'::bpchar,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT categoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT categoria_tipocat_check CHECK ((((tipocat = 'I'::bpchar) OR (tipocat = 'C'::bpchar)) OR (tipocat = 'O'::bpchar)))
);


--
-- Name: sivel2_gen_clase; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_clase (
    id integer DEFAULT nextval('clase_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    id_departamento integer NOT NULL,
    id_municipio integer NOT NULL,
    id_tclase character varying(10),
    latitud double precision,
    longitud double precision,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer NOT NULL,
    CONSTRAINT clase_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_comunidad_filiacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_comunidad_filiacion (
    id_filiacion integer DEFAULT 10 NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_comunidad_organizacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_comunidad_organizacion (
    id_organizacion integer DEFAULT 16 NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_comunidad_profesion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_comunidad_profesion (
    id_profesion integer DEFAULT 22 NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_comunidad_rangoedad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_comunidad_rangoedad (
    id_rangoedad integer DEFAULT 6 NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_comunidad_sectorsocial; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_comunidad_sectorsocial (
    id_sectorsocial integer DEFAULT 15 NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_comunidad_vinculoestado; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_comunidad_vinculoestado (
    id_vinculoestado integer DEFAULT 38 NOT NULL,
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_departamento; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_departamento (
    id integer DEFAULT nextval('departamento_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer NOT NULL,
    CONSTRAINT departamento_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_municipio; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_municipio (
    id integer DEFAULT nextval('municipio_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    id_departamento integer NOT NULL,
    latitud double precision,
    longitud double precision,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer NOT NULL,
    CONSTRAINT municipio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_persona; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_persona (
    id integer DEFAULT nextval('persona_seq'::regclass) NOT NULL,
    nombres character varying(100) COLLATE public.es_co_utf_8 NOT NULL,
    apellidos character varying(100) COLLATE public.es_co_utf_8 NOT NULL,
    anionac integer,
    mesnac integer,
    dianac integer,
    sexo character(1) NOT NULL,
    id_departamento integer,
    id_municipio integer,
    id_clase integer,
    numerodocumento character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer,
    nacionalde integer,
    tdocumento_id integer,
    CONSTRAINT persona_check CHECK (((dianac IS NULL) OR ((((dianac >= 1) AND ((((((((mesnac = 1) OR (mesnac = 3)) OR (mesnac = 5)) OR (mesnac = 7)) OR (mesnac = 8)) OR (mesnac = 10)) OR (mesnac = 12)) AND (dianac <= 31))) OR (((((mesnac = 4) OR (mesnac = 6)) OR (mesnac = 9)) OR (mesnac = 11)) AND (dianac <= 30))) OR ((mesnac = 2) AND (dianac <= 29))))),
    CONSTRAINT persona_mesnac_check CHECK (((mesnac IS NULL) OR ((mesnac >= 1) AND (mesnac <= 12)))),
    CONSTRAINT persona_sexo_check CHECK ((((sexo = 'S'::bpchar) OR (sexo = 'F'::bpchar)) OR (sexo = 'M'::bpchar)))
);


--
-- Name: sivel2_gen_presponsable; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_presponsable (
    id integer DEFAULT nextval('presponsable_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    papa integer,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT presponsable_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: ubicacion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ubicacion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_ubicacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_ubicacion (
    id integer DEFAULT nextval('ubicacion_seq'::regclass) NOT NULL,
    lugar character varying(500) COLLATE public.es_co_utf_8,
    sitio character varying(500) COLLATE public.es_co_utf_8,
    id_clase integer,
    id_municipio integer,
    id_departamento integer,
    id_tsitio integer DEFAULT 1 NOT NULL,
    id_caso integer NOT NULL,
    latitud double precision,
    longitud double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_pais integer
);


--
-- Name: victima_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE victima_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_victima; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_victima (
    id_persona integer NOT NULL,
    id_caso integer NOT NULL,
    hijos integer,
    id_profesion integer DEFAULT 22 NOT NULL,
    id_rangoedad integer DEFAULT 6 NOT NULL,
    id_filiacion integer DEFAULT 10 NOT NULL,
    id_sectorsocial integer DEFAULT 15 NOT NULL,
    id_organizacion integer DEFAULT 16 NOT NULL,
    id_vinculoestado integer DEFAULT 38 NOT NULL,
    organizacionarmada integer DEFAULT 35 NOT NULL,
    anotaciones character varying(1000),
    id_etnia integer DEFAULT 1,
    id_iglesia integer DEFAULT 1,
    orientacionsexual character(1) DEFAULT 'H'::bpchar NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id integer DEFAULT nextval('victima_seq'::regclass) NOT NULL,
    CONSTRAINT victima_hijos_check CHECK (((hijos IS NULL) OR ((hijos >= 0) AND (hijos <= 100)))),
    CONSTRAINT victima_orientacionsexual_check CHECK (((((((orientacionsexual = 'L'::bpchar) OR (orientacionsexual = 'G'::bpchar)) OR (orientacionsexual = 'B'::bpchar)) OR (orientacionsexual = 'T'::bpchar)) OR (orientacionsexual = 'I'::bpchar)) OR (orientacionsexual = 'H'::bpchar)))
);


--
-- Name: sivel2_gen_conscaso1; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sivel2_gen_conscaso1 AS
 SELECT caso.id AS caso_id,
    caso.fecha,
    caso.memo,
    array_to_string(ARRAY( SELECT (((departamento.nombre)::text || ' / '::text) || (municipio.nombre)::text)
           FROM ((sivel2_gen_ubicacion ubicacion
             LEFT JOIN sivel2_gen_departamento departamento ON (((ubicacion.id_pais = departamento.id_pais) AND (ubicacion.id_departamento = departamento.id))))
             LEFT JOIN sivel2_gen_municipio municipio ON ((((ubicacion.id_pais = municipio.id_pais) AND (ubicacion.id_departamento = municipio.id_departamento)) AND (ubicacion.id_municipio = municipio.id))))
          WHERE (ubicacion.id_caso = caso.id)), ', '::text) AS ubicaciones,
    array_to_string(ARRAY( SELECT (((persona.nombres)::text || ' '::text) || (persona.apellidos)::text)
           FROM sivel2_gen_persona persona,
            sivel2_gen_victima victima
          WHERE ((persona.id = victima.id_persona) AND (victima.id_caso = caso.id))), ', '::text) AS victimas,
    array_to_string(ARRAY( SELECT presponsable.nombre
           FROM sivel2_gen_presponsable presponsable,
            sivel2_gen_caso_presponsable caso_presponsable
          WHERE ((presponsable.id = caso_presponsable.id_presponsable) AND (caso_presponsable.id_caso = caso.id))), ', '::text) AS presponsables,
    array_to_string(ARRAY( SELECT (((((((categoria.id_tviolencia)::text || ':'::text) || categoria.id_supracategoria) || ':'::text) || categoria.id) || ' '::text) || (categoria.nombre)::text)
           FROM sivel2_gen_categoria categoria,
            sivel2_gen_acto acto
          WHERE ((categoria.id = acto.id_categoria) AND (acto.id_caso = caso.id))), ', '::text) AS tipificacion
   FROM sivel2_gen_caso caso;


--
-- Name: sivel2_gen_conscaso; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW sivel2_gen_conscaso AS
 SELECT sivel2_gen_conscaso1.caso_id,
    sivel2_gen_conscaso1.fecha,
    sivel2_gen_conscaso1.memo,
    sivel2_gen_conscaso1.ubicaciones,
    sivel2_gen_conscaso1.victimas,
    sivel2_gen_conscaso1.presponsables,
    sivel2_gen_conscaso1.tipificacion,
    to_tsvector('spanish'::regconfig, unaccent(((((((((((((sivel2_gen_conscaso1.caso_id || ' '::text) || replace(((sivel2_gen_conscaso1.fecha)::character varying)::text, '-'::text, ' '::text)) || ' '::text) || sivel2_gen_conscaso1.memo) || ' '::text) || sivel2_gen_conscaso1.ubicaciones) || ' '::text) || sivel2_gen_conscaso1.victimas) || ' '::text) || sivel2_gen_conscaso1.presponsables) || ' '::text) || sivel2_gen_conscaso1.tipificacion))) AS q
   FROM sivel2_gen_conscaso1
  WITH NO DATA;


--
-- Name: sivel2_gen_contexto; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_contexto (
    id integer DEFAULT nextval('contexto_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT contexto_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_escolaridad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_escolaridad (
    id integer DEFAULT nextval('escolaridad_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT escolaridad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_estadocivil; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_estadocivil (
    id integer DEFAULT nextval('estadocivil_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT estadocivil_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_etiqueta; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_etiqueta (
    id integer DEFAULT nextval('etiqueta_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    observaciones character varying(500),
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT etiqueta_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_etnia; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_etnia (
    id integer DEFAULT nextval('etnia_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    descripcion character varying(1000),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT etnia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_ffrecuente; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_ffrecuente (
    id integer DEFAULT nextval('ffrecuente_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    tfuente character varying(25) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT ffrecuente_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_filiacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_filiacion (
    id integer DEFAULT nextval('filiacion_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT filiacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_fotra; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_fotra (
    id integer DEFAULT nextval('fotra_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_frontera; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_frontera (
    id integer DEFAULT nextval('frontera_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT frontera_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_grupoper; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_grupoper (
    id integer DEFAULT nextval('grupoper_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    anotaciones character varying(1000),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_iglesia; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_iglesia (
    id integer DEFAULT nextval('iglesia_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    descripcion character varying(1000),
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT iglesia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_intervalo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_intervalo (
    id integer DEFAULT nextval('intervalo_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    rango character varying(25) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT intervalo_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_maternidad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_maternidad (
    id integer DEFAULT nextval('maternidad_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT maternidad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_organizacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_organizacion (
    id integer DEFAULT nextval('organizacion_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT organizacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_pais; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_pais (
    id integer NOT NULL,
    nombre character varying(200),
    nombreiso character varying(200),
    latitud double precision,
    longitud double precision,
    alfa2 character varying(2),
    alfa3 character varying(3),
    codiso integer,
    div1 character varying(100),
    div2 character varying(100),
    div3 character varying(100),
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_pais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_pais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_pais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_pais_id_seq OWNED BY sivel2_gen_pais.id;


--
-- Name: sivel2_gen_pconsolidado; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_pconsolidado (
    id integer DEFAULT nextval('pconsolidado_seq'::regclass) NOT NULL,
    rotulo character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    tipoviolencia character varying(25) NOT NULL,
    clasificacion character varying(25) NOT NULL,
    peso integer DEFAULT 0,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT pconsolidado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_persona_trelacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_persona_trelacion (
    persona1 integer NOT NULL,
    persona2 integer NOT NULL,
    id_trelacion character(2) DEFAULT 'SI'::bpchar NOT NULL,
    observaciones character varying(200),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_profesion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_profesion (
    id integer DEFAULT nextval('profesion_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT profesion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_rangoedad; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_rangoedad (
    id integer DEFAULT nextval('rangoedad_seq'::regclass) NOT NULL,
    nombre character varying(20) COLLATE public.es_co_utf_8 NOT NULL,
    rango character varying(20) NOT NULL,
    limiteinferior integer DEFAULT 0 NOT NULL,
    limitesuperior integer DEFAULT 0 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT rangoedad_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_rangoedadac; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_rangoedadac (
    id integer NOT NULL,
    nombre character varying(255),
    limiteinferior integer,
    limitesuperior integer,
    fechacreacion date,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_rangoedadac_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_rangoedadac_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_rangoedadac_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_rangoedadac_id_seq OWNED BY sivel2_gen_rangoedadac.id;


--
-- Name: sivel2_gen_regimensalud; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_regimensalud (
    id integer DEFAULT nextval('regimensalud_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT '2013-05-13'::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT regimensalud_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_region; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_region (
    id integer DEFAULT nextval('region_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT region_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_regionsjr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_regionsjr (
    id integer DEFAULT nextval('regionsjr_seq'::regclass) NOT NULL,
    nombre character varying(50) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT regionsjr_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_sectorsocial; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_sectorsocial (
    id integer DEFAULT nextval('sectorsocial_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT sectorsocial_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_supracategoria; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_supracategoria (
    id integer NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    id_tviolencia character varying(1) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT supracategoria_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_tclase; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_tclase (
    id character varying(10) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT tclase_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_tdocumento; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_tdocumento (
    id integer NOT NULL,
    nombre character varying(500) NOT NULL,
    sigla character varying(100),
    formatoregex character varying(500),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sivel2_gen_tdocumento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sivel2_gen_tdocumento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_tdocumento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sivel2_gen_tdocumento_id_seq OWNED BY sivel2_gen_tdocumento.id;


--
-- Name: sivel2_gen_trelacion; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_trelacion (
    id character(2) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    observaciones character varying(200),
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    inverso character varying(2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT trelacion_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: tsitio_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tsitio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_tsitio; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_tsitio (
    id integer DEFAULT nextval('tsitio_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT tsitio_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_tviolencia; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_tviolencia (
    id character(1) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    nomcorto character varying(10) NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT tviolencia_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: sivel2_gen_victimacolectiva; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_victimacolectiva (
    id_grupoper integer NOT NULL,
    id_caso integer NOT NULL,
    personasaprox integer,
    organizacionarmada integer DEFAULT 35,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: vinculoestado_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vinculoestado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sivel2_gen_vinculoestado; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sivel2_gen_vinculoestado (
    id integer DEFAULT nextval('vinculoestado_seq'::regclass) NOT NULL,
    nombre character varying(500) COLLATE public.es_co_utf_8 NOT NULL,
    fechacreacion date NOT NULL,
    fechadeshabilitacion date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT vinculoestado_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion)))
);


--
-- Name: usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE usuario (
    nusuario character varying(15) NOT NULL,
    password character varying(64) DEFAULT ''::character varying NOT NULL,
    nombre character varying(50) COLLATE public.es_co_utf_8,
    descripcion character varying(50),
    rol integer DEFAULT 4,
    idioma character varying(6) DEFAULT 'es_CO'::character varying NOT NULL,
    id integer DEFAULT nextval('usuario_seq'::regclass) NOT NULL,
    fechacreacion date DEFAULT ('now'::text)::date NOT NULL,
    fechadeshabilitacion date,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    failed_attempts integer,
    unlock_token character varying(64),
    locked_at timestamp without time zone,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    regionsjr_id integer,
    CONSTRAINT usuario_check CHECK (((fechadeshabilitacion IS NULL) OR (fechadeshabilitacion >= fechacreacion))),
    CONSTRAINT usuario_rol_check CHECK (((rol >= 1) AND (rol <= 6)))
);


--
-- Name: vvictimasoundexesp; Type: MATERIALIZED VIEW; Schema: public; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW vvictimasoundexesp AS
 SELECT sivel2_gen_victima.id_caso,
    sivel2_gen_persona.id AS id_persona,
    (((sivel2_gen_persona.nombres)::text || ' '::text) || (sivel2_gen_persona.apellidos)::text) AS nomap,
    ( SELECT array_to_string(array_agg(soundexesp(n.s)), ' '::text) AS array_to_string
           FROM ( SELECT unnest(string_to_array(regexp_replace((((sivel2_gen_persona.nombres)::text || ' '::text) || (sivel2_gen_persona.apellidos)::text), '  *'::text, ' '::text), ' '::text)) AS s
                  ORDER BY unnest(string_to_array(regexp_replace((((sivel2_gen_persona.nombres)::text || ' '::text) || (sivel2_gen_persona.apellidos)::text), '  *'::text, ' '::text), ' '::text))) n) AS nomsoundexesp
   FROM sivel2_gen_persona,
    sivel2_gen_victima
  WHERE (sivel2_gen_persona.id = sivel2_gen_victima.id_persona)
  WITH NO DATA;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actividad ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_actividad_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actividad_rangoedadac ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_actividad_rangoedadac_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actividadarea ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_actividadarea_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actividadareas_actividad ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_actividadareas_actividad_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_anexoactividad ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_anexoactividad_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_pais ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_pais_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_rangoedadac ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_rangoedadac_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_tdocumento ALTER COLUMN id SET DEFAULT nextval('sivel2_gen_tdocumento_id_seq'::regclass);


--
-- Name: actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_actividad
    ADD CONSTRAINT actividad_pkey PRIMARY KEY (id);


--
-- Name: actividad_rangoedadac_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_actividad_rangoedadac
    ADD CONSTRAINT actividad_rangoedadac_pkey PRIMARY KEY (id);


--
-- Name: actividadarea_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_actividadarea
    ADD CONSTRAINT actividadarea_pkey PRIMARY KEY (id);


--
-- Name: actividadareas_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_actividadareas_actividad
    ADD CONSTRAINT actividadareas_actividad_pkey PRIMARY KEY (id);


--
-- Name: actividadoficio_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_actividadoficio
    ADD CONSTRAINT actividadoficio_pkey PRIMARY KEY (id);


--
-- Name: acto_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_id_key UNIQUE (id);


--
-- Name: acto_id_presponsable_id_categoria_id_persona_id_caso_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_id_presponsable_id_categoria_id_persona_id_caso_key UNIQUE (id_presponsable, id_categoria, id_persona, id_caso);


--
-- Name: acto_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_pkey PRIMARY KEY (id);


--
-- Name: actocolectivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_pkey PRIMARY KEY (id_presponsable, id_categoria, id_grupoper, id_caso);


--
-- Name: anexo_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_anexo
    ADD CONSTRAINT anexo_pkey PRIMARY KEY (id);


--
-- Name: anexoactividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_anexoactividad
    ADD CONSTRAINT anexoactividad_pkey PRIMARY KEY (id);


--
-- Name: antecedente_caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_pkey PRIMARY KEY (id_antecedente, id_caso);


--
-- Name: antecedente_comunidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_antecedente_comunidad
    ADD CONSTRAINT antecedente_comunidad_pkey PRIMARY KEY (id_antecedente, id_grupoper, id_caso);


--
-- Name: antecedente_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_antecedente
    ADD CONSTRAINT antecedente_pkey PRIMARY KEY (id);


--
-- Name: antecedente_victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_pkey PRIMARY KEY (id_antecedente, id_persona, id_caso);


--
-- Name: caso_contexto_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_pkey PRIMARY KEY (id_caso, id_contexto);


--
-- Name: caso_etiqueta_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_key UNIQUE (id);


--
-- Name: caso_etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_pkey PRIMARY KEY (id);


--
-- Name: caso_ffrecuente_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_ffrecuente
    ADD CONSTRAINT caso_ffrecuente_pkey PRIMARY KEY (fecha, id_ffrecuente, id_caso);


--
-- Name: caso_fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_pkey PRIMARY KEY (id_caso, id_fotra, fecha);


--
-- Name: caso_frontera_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_pkey PRIMARY KEY (id_frontera, id_caso);


--
-- Name: caso_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso
    ADD CONSTRAINT caso_pkey PRIMARY KEY (id);


--
-- Name: caso_presponsable_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_key UNIQUE (id);


--
-- Name: caso_presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_pkey PRIMARY KEY (id);


--
-- Name: caso_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_pkey PRIMARY KEY (id_region, id_caso);


--
-- Name: categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- Name: clase_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_clase
    ADD CONSTRAINT clase_pkey PRIMARY KEY (id, id_municipio, id_departamento, id_pais);


--
-- Name: comunidad_filiacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_comunidad_filiacion
    ADD CONSTRAINT comunidad_filiacion_pkey PRIMARY KEY (id_filiacion, id_grupoper, id_caso);


--
-- Name: comunidad_organizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_comunidad_organizacion
    ADD CONSTRAINT comunidad_organizacion_pkey PRIMARY KEY (id_organizacion, id_grupoper, id_caso);


--
-- Name: comunidad_profesion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_comunidad_profesion
    ADD CONSTRAINT comunidad_profesion_pkey PRIMARY KEY (id_profesion, id_grupoper, id_caso);


--
-- Name: comunidad_rangoedad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_comunidad_rangoedad
    ADD CONSTRAINT comunidad_rangoedad_pkey PRIMARY KEY (id_rangoedad, id_grupoper, id_caso);


--
-- Name: comunidad_sectorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_comunidad_sectorsocial
    ADD CONSTRAINT comunidad_sectorsocial_pkey PRIMARY KEY (id_sectorsocial, id_grupoper, id_caso);


--
-- Name: comunidad_vinculoestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_comunidad_vinculoestado
    ADD CONSTRAINT comunidad_vinculoestado_pkey PRIMARY KEY (id_vinculoestado, id_grupoper, id_caso);


--
-- Name: contexto_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_contexto
    ADD CONSTRAINT contexto_pkey PRIMARY KEY (id);


--
-- Name: departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id, id_pais);


--
-- Name: escolaridad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_escolaridad
    ADD CONSTRAINT escolaridad_pkey PRIMARY KEY (id);


--
-- Name: estadocivil_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_estadocivil
    ADD CONSTRAINT estadocivil_pkey PRIMARY KEY (id);


--
-- Name: etiqueta_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_etiqueta
    ADD CONSTRAINT etiqueta_pkey PRIMARY KEY (id);


--
-- Name: etnia_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_etnia
    ADD CONSTRAINT etnia_pkey PRIMARY KEY (id);


--
-- Name: ffrecuente_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_ffrecuente
    ADD CONSTRAINT ffrecuente_pkey PRIMARY KEY (id);


--
-- Name: filiacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_filiacion
    ADD CONSTRAINT filiacion_pkey PRIMARY KEY (id);


--
-- Name: fotra_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_fotra
    ADD CONSTRAINT fotra_pkey PRIMARY KEY (id);


--
-- Name: frontera_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_frontera
    ADD CONSTRAINT frontera_pkey PRIMARY KEY (id);


--
-- Name: grupoper_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_grupoper
    ADD CONSTRAINT grupoper_pkey PRIMARY KEY (id);


--
-- Name: iglesia_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_iglesia
    ADD CONSTRAINT iglesia_pkey PRIMARY KEY (id);


--
-- Name: intervalo_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_intervalo
    ADD CONSTRAINT intervalo_pkey PRIMARY KEY (id);


--
-- Name: maternidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_maternidad
    ADD CONSTRAINT maternidad_pkey PRIMARY KEY (id);


--
-- Name: municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id, id_departamento, id_pais);


--
-- Name: organizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_organizacion
    ADD CONSTRAINT organizacion_pkey PRIMARY KEY (id);


--
-- Name: pais_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_pais
    ADD CONSTRAINT pais_pkey PRIMARY KEY (id);


--
-- Name: pconsolidado_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_pconsolidado
    ADD CONSTRAINT pconsolidado_pkey PRIMARY KEY (id);


--
-- Name: persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);


--
-- Name: persona_trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_persona_trelacion
    ADD CONSTRAINT persona_trelacion_pkey PRIMARY KEY (persona1, persona2, id_trelacion);


--
-- Name: presponsable_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_pkey PRIMARY KEY (id);


--
-- Name: profesion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_profesion
    ADD CONSTRAINT profesion_pkey PRIMARY KEY (id);


--
-- Name: rangoedad_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_rangoedad
    ADD CONSTRAINT rangoedad_pkey PRIMARY KEY (id);


--
-- Name: rangoedadac_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_rangoedadac
    ADD CONSTRAINT rangoedadac_pkey PRIMARY KEY (id);


--
-- Name: regimensalud_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_regimensalud
    ADD CONSTRAINT regimensalud_pkey PRIMARY KEY (id);


--
-- Name: region_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: regionsjr_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_regionsjr
    ADD CONSTRAINT regionsjr_pkey PRIMARY KEY (id);


--
-- Name: sectorsocial_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_sectorsocial
    ADD CONSTRAINT sectorsocial_pkey PRIMARY KEY (id);


--
-- Name: supracategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_supracategoria
    ADD CONSTRAINT supracategoria_pkey PRIMARY KEY (id, id_tviolencia);


--
-- Name: tclase_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_tclase
    ADD CONSTRAINT tclase_pkey PRIMARY KEY (id);


--
-- Name: tdocumento_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_tdocumento
    ADD CONSTRAINT tdocumento_pkey PRIMARY KEY (id);


--
-- Name: trelacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_trelacion
    ADD CONSTRAINT trelacion_pkey PRIMARY KEY (id);


--
-- Name: tsitio_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_tsitio
    ADD CONSTRAINT tsitio_pkey PRIMARY KEY (id);


--
-- Name: tviolencia_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_tviolencia
    ADD CONSTRAINT tviolencia_pkey PRIMARY KEY (id);


--
-- Name: ubicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_pkey PRIMARY KEY (id);


--
-- Name: usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: victima_id_caso_id_persona_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_id_persona_key UNIQUE (id_caso, id_persona);


--
-- Name: victima_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_key UNIQUE (id);


--
-- Name: victima_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_pkey PRIMARY KEY (id);


--
-- Name: victimacolectiva_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_pkey PRIMARY KEY (id_grupoper, id_caso);


--
-- Name: vinculoestado_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sivel2_gen_vinculoestado
    ADD CONSTRAINT vinculoestado_pkey PRIMARY KEY (id);


--
-- Name: busca_sivel2_gen_conscaso; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX busca_sivel2_gen_conscaso ON sivel2_gen_conscaso USING gin (q);


--
-- Name: index_sivel2_gen_actividad_on_rangoedadac_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sivel2_gen_actividad_on_rangoedadac_id ON sivel2_gen_actividad USING btree (rangoedadac_id);


--
-- Name: index_sivel2_gen_actividad_rangoedadac_on_actividad_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sivel2_gen_actividad_rangoedadac_on_actividad_id ON sivel2_gen_actividad_rangoedadac USING btree (actividad_id);


--
-- Name: index_sivel2_gen_actividad_rangoedadac_on_rangoedadac_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sivel2_gen_actividad_rangoedadac_on_rangoedadac_id ON sivel2_gen_actividad_rangoedadac USING btree (rangoedadac_id);


--
-- Name: index_sivel2_gen_anexoactividad_on_actividad_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sivel2_gen_anexoactividad_on_actividad_id ON sivel2_gen_anexoactividad USING btree (actividad_id);


--
-- Name: index_usuario_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_usuario_on_email ON usuario USING btree (email);


--
-- Name: index_usuario_on_regionsjr_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_usuario_on_regionsjr_id ON usuario USING btree (regionsjr_id);


--
-- Name: index_usuario_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_usuario_on_reset_password_token ON usuario USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: usuario_nusuario; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX usuario_nusuario ON usuario USING btree (nusuario);


--
-- Name: actividad_regionsjr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actividad
    ADD CONSTRAINT actividad_regionsjr_id_fkey FOREIGN KEY (regionsjr_id) REFERENCES sivel2_gen_regionsjr(id);


--
-- Name: acto_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: acto_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES sivel2_gen_categoria(id);


--
-- Name: acto_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES sivel2_gen_persona(id);


--
-- Name: acto_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_acto
    ADD CONSTRAINT acto_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES sivel2_gen_presponsable(id);


--
-- Name: actocolectivo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: actocolectivo_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES sivel2_gen_categoria(id);


--
-- Name: actocolectivo_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: actocolectivo_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: actocolectivo_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_actocolectivo
    ADD CONSTRAINT actocolectivo_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES sivel2_gen_presponsable(id);


--
-- Name: anexo_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_anexo
    ADD CONSTRAINT anexo_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: anexo_id_ffrecuente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_anexo
    ADD CONSTRAINT anexo_id_ffrecuente_fkey FOREIGN KEY (id_ffrecuente) REFERENCES sivel2_gen_ffrecuente(id);


--
-- Name: anexo_id_fotra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_anexo
    ADD CONSTRAINT anexo_id_fotra_fkey FOREIGN KEY (id_fotra) REFERENCES sivel2_gen_fotra(id);


--
-- Name: antecedente_caso_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_antecedente_fkey FOREIGN KEY (id_antecedente) REFERENCES sivel2_gen_antecedente(id);


--
-- Name: antecedente_caso_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_caso
    ADD CONSTRAINT antecedente_caso_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: antecedente_comunidad_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_comunidad
    ADD CONSTRAINT antecedente_comunidad_id_antecedente_fkey FOREIGN KEY (id_antecedente) REFERENCES sivel2_gen_antecedente(id);


--
-- Name: antecedente_comunidad_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_comunidad
    ADD CONSTRAINT antecedente_comunidad_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: antecedente_comunidad_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_comunidad
    ADD CONSTRAINT antecedente_comunidad_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: antecedente_comunidad_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_comunidad
    ADD CONSTRAINT antecedente_comunidad_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: antecedente_victima_id_antecedente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_antecedente_fkey FOREIGN KEY (id_antecedente) REFERENCES sivel2_gen_antecedente(id);


--
-- Name: antecedente_victima_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: antecedente_victima_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES sivel2_gen_persona(id);


--
-- Name: antecedente_victima_id_victima_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_victima
    ADD CONSTRAINT antecedente_victima_id_victima_fkey FOREIGN KEY (id_victima) REFERENCES sivel2_gen_victima(id);


--
-- Name: caso_categoria_presponsable_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_categoria_presponsable_id_caso_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_caso_presponsable_fkey FOREIGN KEY (id_caso_presponsable) REFERENCES sivel2_gen_caso_presponsable(id);


--
-- Name: caso_categoria_presponsable_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES sivel2_gen_categoria(id);


--
-- Name: caso_categoria_presponsable_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES sivel2_gen_presponsable(id);


--
-- Name: caso_categoria_presponsable_id_supracategoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_supracategoria_fkey FOREIGN KEY (id_supracategoria, id_tviolencia) REFERENCES sivel2_gen_supracategoria(id, id_tviolencia);


--
-- Name: caso_categoria_presponsable_id_tviolencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_categoria_presponsable
    ADD CONSTRAINT caso_categoria_presponsable_id_tviolencia_fkey FOREIGN KEY (id_tviolencia) REFERENCES sivel2_gen_tviolencia(id);


--
-- Name: caso_contexto_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_contexto_id_contexto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_contexto
    ADD CONSTRAINT caso_contexto_id_contexto_fkey FOREIGN KEY (id_contexto) REFERENCES sivel2_gen_contexto(id);


--
-- Name: caso_etiqueta_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_etiqueta_id_etiqueta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_etiqueta_fkey FOREIGN KEY (id_etiqueta) REFERENCES sivel2_gen_etiqueta(id);


--
-- Name: caso_etiqueta_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_etiqueta
    ADD CONSTRAINT caso_etiqueta_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id);


--
-- Name: caso_ffrecuente_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_ffrecuente
    ADD CONSTRAINT caso_ffrecuente_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_ffrecuente_id_ffrecuente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_ffrecuente
    ADD CONSTRAINT caso_ffrecuente_id_ffrecuente_fkey FOREIGN KEY (id_ffrecuente) REFERENCES sivel2_gen_ffrecuente(id);


--
-- Name: caso_fotra_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_fotra_id_fotra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_fotra
    ADD CONSTRAINT caso_fotra_id_fotra_fkey FOREIGN KEY (id_fotra) REFERENCES sivel2_gen_fotra(id);


--
-- Name: caso_frontera_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_frontera_id_frontera_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_frontera
    ADD CONSTRAINT caso_frontera_id_frontera_fkey FOREIGN KEY (id_frontera) REFERENCES sivel2_gen_frontera(id);


--
-- Name: caso_funcionario_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_funcionario_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_id_intervalo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso
    ADD CONSTRAINT caso_id_intervalo_fkey FOREIGN KEY (id_intervalo) REFERENCES sivel2_gen_intervalo(id);


--
-- Name: caso_presponsable_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_presponsable_id_presponsable_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_presponsable
    ADD CONSTRAINT caso_presponsable_id_presponsable_fkey FOREIGN KEY (id_presponsable) REFERENCES sivel2_gen_presponsable(id);


--
-- Name: caso_region_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: caso_region_id_region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_region
    ADD CONSTRAINT caso_region_id_region_fkey FOREIGN KEY (id_region) REFERENCES sivel2_gen_region(id);


--
-- Name: caso_usuario_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_caso_usuario
    ADD CONSTRAINT caso_usuario_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES usuario(id);


--
-- Name: categoria_contadaen_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_categoria
    ADD CONSTRAINT categoria_contadaen_fkey FOREIGN KEY (contadaen) REFERENCES sivel2_gen_categoria(id);


--
-- Name: categoria_id_pconsolidado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_categoria
    ADD CONSTRAINT categoria_id_pconsolidado_fkey FOREIGN KEY (id_pconsolidado) REFERENCES sivel2_gen_pconsolidado(id);


--
-- Name: categoria_id_supracategoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_categoria
    ADD CONSTRAINT categoria_id_supracategoria_fkey FOREIGN KEY (id_supracategoria, id_tviolencia) REFERENCES sivel2_gen_supracategoria(id, id_tviolencia);


--
-- Name: categoria_id_tviolencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_categoria
    ADD CONSTRAINT categoria_id_tviolencia_fkey FOREIGN KEY (id_tviolencia) REFERENCES sivel2_gen_tviolencia(id);


--
-- Name: clase_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_clase
    ADD CONSTRAINT clase_id_departamento_fkey FOREIGN KEY (id_departamento, id_pais) REFERENCES sivel2_gen_departamento(id, id_pais);


--
-- Name: clase_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_clase
    ADD CONSTRAINT clase_id_municipio_fkey FOREIGN KEY (id_municipio, id_departamento, id_pais) REFERENCES sivel2_gen_municipio(id, id_departamento, id_pais);


--
-- Name: clase_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_clase
    ADD CONSTRAINT clase_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES sivel2_gen_pais(id);


--
-- Name: clase_id_tclase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_clase
    ADD CONSTRAINT clase_id_tclase_fkey FOREIGN KEY (id_tclase) REFERENCES sivel2_gen_tclase(id);


--
-- Name: comunidad_filiacion_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_filiacion
    ADD CONSTRAINT comunidad_filiacion_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: comunidad_filiacion_id_filiacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_filiacion
    ADD CONSTRAINT comunidad_filiacion_id_filiacion_fkey FOREIGN KEY (id_filiacion) REFERENCES sivel2_gen_filiacion(id);


--
-- Name: comunidad_filiacion_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_filiacion
    ADD CONSTRAINT comunidad_filiacion_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: comunidad_filiacion_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_filiacion
    ADD CONSTRAINT comunidad_filiacion_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: comunidad_organizacion_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_organizacion
    ADD CONSTRAINT comunidad_organizacion_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: comunidad_organizacion_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_organizacion
    ADD CONSTRAINT comunidad_organizacion_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: comunidad_organizacion_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_organizacion
    ADD CONSTRAINT comunidad_organizacion_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: comunidad_organizacion_id_organizacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_organizacion
    ADD CONSTRAINT comunidad_organizacion_id_organizacion_fkey FOREIGN KEY (id_organizacion) REFERENCES sivel2_gen_organizacion(id);


--
-- Name: comunidad_profesion_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_profesion
    ADD CONSTRAINT comunidad_profesion_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: comunidad_profesion_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_profesion
    ADD CONSTRAINT comunidad_profesion_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: comunidad_profesion_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_profesion
    ADD CONSTRAINT comunidad_profesion_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: comunidad_profesion_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_profesion
    ADD CONSTRAINT comunidad_profesion_id_profesion_fkey FOREIGN KEY (id_profesion) REFERENCES sivel2_gen_profesion(id);


--
-- Name: comunidad_rangoedad_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_rangoedad
    ADD CONSTRAINT comunidad_rangoedad_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: comunidad_rangoedad_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_rangoedad
    ADD CONSTRAINT comunidad_rangoedad_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: comunidad_rangoedad_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_rangoedad
    ADD CONSTRAINT comunidad_rangoedad_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: comunidad_rangoedad_id_rangoedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_rangoedad
    ADD CONSTRAINT comunidad_rangoedad_id_rangoedad_fkey FOREIGN KEY (id_rangoedad) REFERENCES sivel2_gen_rangoedad(id);


--
-- Name: comunidad_sectorsocial_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_sectorsocial
    ADD CONSTRAINT comunidad_sectorsocial_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: comunidad_sectorsocial_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_sectorsocial
    ADD CONSTRAINT comunidad_sectorsocial_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: comunidad_sectorsocial_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_sectorsocial
    ADD CONSTRAINT comunidad_sectorsocial_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: comunidad_sectorsocial_id_sector_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_sectorsocial
    ADD CONSTRAINT comunidad_sectorsocial_id_sector_fkey FOREIGN KEY (id_sectorsocial) REFERENCES sivel2_gen_sectorsocial(id);


--
-- Name: comunidad_vinculoestado_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_vinculoestado
    ADD CONSTRAINT comunidad_vinculoestado_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: comunidad_vinculoestado_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_vinculoestado
    ADD CONSTRAINT comunidad_vinculoestado_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: comunidad_vinculoestado_id_grupoper_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_vinculoestado
    ADD CONSTRAINT comunidad_vinculoestado_id_grupoper_fkey1 FOREIGN KEY (id_grupoper, id_caso) REFERENCES sivel2_gen_victimacolectiva(id_grupoper, id_caso);


--
-- Name: comunidad_vinculoestado_id_vinculoestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_comunidad_vinculoestado
    ADD CONSTRAINT comunidad_vinculoestado_id_vinculoestado_fkey FOREIGN KEY (id_vinculoestado) REFERENCES sivel2_gen_vinculoestado(id);


--
-- Name: departamento_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_departamento
    ADD CONSTRAINT departamento_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES sivel2_gen_pais(id);


--
-- Name: municipio_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_municipio
    ADD CONSTRAINT municipio_id_departamento_fkey FOREIGN KEY (id_departamento, id_pais) REFERENCES sivel2_gen_departamento(id, id_pais);


--
-- Name: municipio_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_municipio
    ADD CONSTRAINT municipio_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES sivel2_gen_pais(id);


--
-- Name: persona_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_id_clase_fkey FOREIGN KEY (id_clase, id_municipio, id_departamento, id_pais) REFERENCES sivel2_gen_clase(id, id_municipio, id_departamento, id_pais);


--
-- Name: persona_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_id_departamento_fkey FOREIGN KEY (id_departamento, id_pais) REFERENCES sivel2_gen_departamento(id, id_pais);


--
-- Name: persona_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_id_municipio_fkey FOREIGN KEY (id_municipio, id_departamento, id_pais) REFERENCES sivel2_gen_municipio(id, id_departamento, id_pais);


--
-- Name: persona_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES sivel2_gen_pais(id);


--
-- Name: persona_nacionalde_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_nacionalde_fkey FOREIGN KEY (nacionalde) REFERENCES sivel2_gen_pais(id);


--
-- Name: persona_tdocumento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona
    ADD CONSTRAINT persona_tdocumento_id_fkey FOREIGN KEY (tdocumento_id) REFERENCES sivel2_gen_tdocumento(id);


--
-- Name: persona_trelacion_id_trelacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona_trelacion
    ADD CONSTRAINT persona_trelacion_id_trelacion_fkey FOREIGN KEY (id_trelacion) REFERENCES sivel2_gen_trelacion(id);


--
-- Name: persona_trelacion_persona1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona1_fkey FOREIGN KEY (persona1) REFERENCES sivel2_gen_persona(id);


--
-- Name: persona_trelacion_persona2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_persona_trelacion
    ADD CONSTRAINT persona_trelacion_persona2_fkey FOREIGN KEY (persona2) REFERENCES sivel2_gen_persona(id);


--
-- Name: presponsable_papa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_presponsable
    ADD CONSTRAINT presponsable_papa_fkey FOREIGN KEY (papa) REFERENCES sivel2_gen_presponsable(id);


--
-- Name: supracategoria_id_tviolencia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_supracategoria
    ADD CONSTRAINT supracategoria_id_tviolencia_fkey FOREIGN KEY (id_tviolencia) REFERENCES sivel2_gen_tviolencia(id);


--
-- Name: trelacion_inverso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_trelacion
    ADD CONSTRAINT trelacion_inverso_fkey FOREIGN KEY (inverso) REFERENCES sivel2_gen_trelacion(id);


--
-- Name: ubicacion_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: ubicacion_id_clase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_id_clase_fkey FOREIGN KEY (id_clase, id_municipio, id_departamento, id_pais) REFERENCES sivel2_gen_clase(id, id_municipio, id_departamento, id_pais);


--
-- Name: ubicacion_id_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_id_departamento_fkey FOREIGN KEY (id_departamento, id_pais) REFERENCES sivel2_gen_departamento(id, id_pais);


--
-- Name: ubicacion_id_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_id_municipio_fkey FOREIGN KEY (id_municipio, id_departamento, id_pais) REFERENCES sivel2_gen_municipio(id, id_departamento, id_pais);


--
-- Name: ubicacion_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES sivel2_gen_pais(id);


--
-- Name: ubicacion_id_tsitio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_ubicacion
    ADD CONSTRAINT ubicacion_id_tsitio_fkey FOREIGN KEY (id_tsitio) REFERENCES sivel2_gen_tsitio(id);


--
-- Name: victima_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_antecedente_victima
    ADD CONSTRAINT victima_fkey FOREIGN KEY (id_caso, id_persona) REFERENCES sivel2_gen_victima(id_caso, id_persona);


--
-- Name: victima_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: victima_id_etnia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_etnia_fkey FOREIGN KEY (id_etnia) REFERENCES sivel2_gen_etnia(id);


--
-- Name: victima_id_filiacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_filiacion_fkey FOREIGN KEY (id_filiacion) REFERENCES sivel2_gen_filiacion(id);


--
-- Name: victima_id_iglesia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_iglesia_fkey FOREIGN KEY (id_iglesia) REFERENCES sivel2_gen_iglesia(id);


--
-- Name: victima_id_organizacion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_organizacion_fkey FOREIGN KEY (id_organizacion) REFERENCES sivel2_gen_organizacion(id);


--
-- Name: victima_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES sivel2_gen_persona(id);


--
-- Name: victima_id_profesion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_profesion_fkey FOREIGN KEY (id_profesion) REFERENCES sivel2_gen_profesion(id);


--
-- Name: victima_id_rangoedad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_rangoedad_fkey FOREIGN KEY (id_rangoedad) REFERENCES sivel2_gen_rangoedad(id);


--
-- Name: victima_id_sectorsocial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_sectorsocial_fkey FOREIGN KEY (id_sectorsocial) REFERENCES sivel2_gen_sectorsocial(id);


--
-- Name: victima_id_vinculoestado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_id_vinculoestado_fkey FOREIGN KEY (id_vinculoestado) REFERENCES sivel2_gen_vinculoestado(id);


--
-- Name: victima_organizacionarmada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victima
    ADD CONSTRAINT victima_organizacionarmada_fkey FOREIGN KEY (organizacionarmada) REFERENCES sivel2_gen_presponsable(id);


--
-- Name: victimacolectiva_id_caso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_id_caso_fkey FOREIGN KEY (id_caso) REFERENCES sivel2_gen_caso(id);


--
-- Name: victimacolectiva_id_grupoper_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_id_grupoper_fkey FOREIGN KEY (id_grupoper) REFERENCES sivel2_gen_grupoper(id);


--
-- Name: victimacolectiva_organizacionarmada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sivel2_gen_victimacolectiva
    ADD CONSTRAINT victimacolectiva_organizacionarmada_fkey FOREIGN KEY (organizacionarmada) REFERENCES sivel2_gen_presponsable(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO public, pg_catalog;

INSERT INTO schema_migrations (version) VALUES ('20131128151014');

INSERT INTO schema_migrations (version) VALUES ('20131204135932');

INSERT INTO schema_migrations (version) VALUES ('20131204140000');

INSERT INTO schema_migrations (version) VALUES ('20131204143718');

INSERT INTO schema_migrations (version) VALUES ('20131204183530');

INSERT INTO schema_migrations (version) VALUES ('20131206081531');

INSERT INTO schema_migrations (version) VALUES ('20131210221541');

INSERT INTO schema_migrations (version) VALUES ('20131220103409');

INSERT INTO schema_migrations (version) VALUES ('20131223175141');

INSERT INTO schema_migrations (version) VALUES ('20140117212555');

INSERT INTO schema_migrations (version) VALUES ('20140129151136');

INSERT INTO schema_migrations (version) VALUES ('20140207102709');

INSERT INTO schema_migrations (version) VALUES ('20140207102739');

INSERT INTO schema_migrations (version) VALUES ('20140211162355');

INSERT INTO schema_migrations (version) VALUES ('20140211164659');

INSERT INTO schema_migrations (version) VALUES ('20140211172443');

INSERT INTO schema_migrations (version) VALUES ('20140313012209');

INSERT INTO schema_migrations (version) VALUES ('20140514142421');

INSERT INTO schema_migrations (version) VALUES ('20140518120059');

INSERT INTO schema_migrations (version) VALUES ('20140527110223');

INSERT INTO schema_migrations (version) VALUES ('20140528043115');

INSERT INTO schema_migrations (version) VALUES ('20140613044320');

INSERT INTO schema_migrations (version) VALUES ('20140704035033');

INSERT INTO schema_migrations (version) VALUES ('20140804194616');

INSERT INTO schema_migrations (version) VALUES ('20140804200235');

INSERT INTO schema_migrations (version) VALUES ('20140804202100');

INSERT INTO schema_migrations (version) VALUES ('20140804202101');

INSERT INTO schema_migrations (version) VALUES ('20140804202958');

INSERT INTO schema_migrations (version) VALUES ('20140804210000');

INSERT INTO schema_migrations (version) VALUES ('20140815111351');

INSERT INTO schema_migrations (version) VALUES ('20140815111352');

INSERT INTO schema_migrations (version) VALUES ('20140815121224');

INSERT INTO schema_migrations (version) VALUES ('20140815123542');

INSERT INTO schema_migrations (version) VALUES ('20140815124157');

INSERT INTO schema_migrations (version) VALUES ('20140815124606');

INSERT INTO schema_migrations (version) VALUES ('20140827142659');

INSERT INTO schema_migrations (version) VALUES ('20140901105741');

INSERT INTO schema_migrations (version) VALUES ('20140901106000');

INSERT INTO schema_migrations (version) VALUES ('20140909165233');

INSERT INTO schema_migrations (version) VALUES ('20140918115412');

INSERT INTO schema_migrations (version) VALUES ('20140922102737');

INSERT INTO schema_migrations (version) VALUES ('20140922110956');

INSERT INTO schema_migrations (version) VALUES ('20141002140242');

INSERT INTO schema_migrations (version) VALUES ('20141111102451');

INSERT INTO schema_migrations (version) VALUES ('20141111203313');

INSERT INTO schema_migrations (version) VALUES ('20141126085907');


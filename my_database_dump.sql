--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg120+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: add_new_client(character varying, character varying, text); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.add_new_client(fullname character varying, phone character varying, preferences text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Clients (FullName, Phone, FoodPreferences) VALUES (fullname, phone, preferences);
END;
$$;


ALTER FUNCTION public.add_new_client(fullname character varying, phone character varying, preferences text) OWNER TO root;

--
-- Name: check_expiration_date(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.check_expiration_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.ExpirationDate < CURRENT_DATE THEN
        RAISE EXCEPTION 'Срок годности ингредиента истёк: %', NEW.Name;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_expiration_date() OWNER TO root;

--
-- Name: get_dish_info(integer); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.get_dish_info(dish_id integer) RETURNS TABLE(dishname character varying, dishdescription text, dishprice numeric, categoryname character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT d.Name, d.Description, d.Price, c.Category
    FROM Dishes d
    JOIN Categories c ON d.Category = c.CategoryID
    WHERE d.DishID = dish_id;
END;
$$;


ALTER FUNCTION public.get_dish_info(dish_id integer) OWNER TO root;

--
-- Name: update_total_amount(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.update_total_amount() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Orders
    SET TotalAmount = TotalAmount + (SELECT Price FROM Dishes WHERE DishID = NEW.DishID) * NEW.Quantity
    WHERE OrderID = NEW.OrderID;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_total_amount() OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.clients (
    clientid integer NOT NULL,
    fullname character varying(255) NOT NULL,
    phone character varying(50),
    foodpreferences text
);


ALTER TABLE public.clients OWNER TO root;

--
-- Name: clients_clientid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.clients_clientid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clients_clientid_seq OWNER TO root;

--
-- Name: clients_clientid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.clients_clientid_seq OWNED BY public.clients.clientid;


--
-- Name: dishes; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.dishes (
    dishid integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    category character varying(255)
);


ALTER TABLE public.dishes OWNER TO root;

--
-- Name: dishes_dishid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.dishes_dishid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dishes_dishid_seq OWNER TO root;

--
-- Name: dishes_dishid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.dishes_dishid_seq OWNED BY public.dishes.dishid;


--
-- Name: dishingredients; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.dishingredients (
    dishid integer NOT NULL,
    ingredientid integer NOT NULL
);


ALTER TABLE public.dishingredients OWNER TO root;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.employees (
    employeeid integer NOT NULL,
    fullname character varying(255) NOT NULL,
    "position" character varying(255),
    salary numeric(10,2),
    startdate date,
    restaurantid integer
);


ALTER TABLE public.employees OWNER TO root;

--
-- Name: employees_employeeid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.employees_employeeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_employeeid_seq OWNER TO root;

--
-- Name: employees_employeeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.employees_employeeid_seq OWNED BY public.employees.employeeid;


--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.ingredients (
    ingredientid integer NOT NULL,
    name character varying(255) NOT NULL,
    cost numeric(10,2) NOT NULL,
    expirationdate date NOT NULL,
    supplierid integer
);


ALTER TABLE public.ingredients OWNER TO root;

--
-- Name: ingredients_ingredientid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.ingredients_ingredientid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingredients_ingredientid_seq OWNER TO root;

--
-- Name: ingredients_ingredientid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.ingredients_ingredientid_seq OWNED BY public.ingredients.ingredientid;


--
-- Name: orderdetails; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.orderdetails (
    orderdetailid integer NOT NULL,
    orderid integer,
    dishid integer,
    quantity integer
);


ALTER TABLE public.orderdetails OWNER TO root;

--
-- Name: orderdetails_orderdetailid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.orderdetails_orderdetailid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orderdetails_orderdetailid_seq OWNER TO root;

--
-- Name: orderdetails_orderdetailid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.orderdetails_orderdetailid_seq OWNED BY public.orderdetails.orderdetailid;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.orders (
    orderid integer NOT NULL,
    orderdate timestamp without time zone NOT NULL,
    tablenumber integer,
    totalamount numeric(10,2) NOT NULL,
    status character varying(50),
    clientid integer
);


ALTER TABLE public.orders OWNER TO root;

--
-- Name: orders_orderid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.orders_orderid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_orderid_seq OWNER TO root;

--
-- Name: orders_orderid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.orders_orderid_seq OWNED BY public.orders.orderid;


--
-- Name: restaurants; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.restaurants (
    restaurantid integer NOT NULL,
    name character varying(255) NOT NULL,
    address text NOT NULL,
    phone character varying(50),
    operatinghours character varying(255)
);


ALTER TABLE public.restaurants OWNER TO root;

--
-- Name: restaurants_restaurantid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.restaurants_restaurantid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.restaurants_restaurantid_seq OWNER TO root;

--
-- Name: restaurants_restaurantid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.restaurants_restaurantid_seq OWNED BY public.restaurants.restaurantid;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.reviews (
    reviewid integer NOT NULL,
    text text NOT NULL,
    rating integer,
    reviewdate timestamp without time zone NOT NULL,
    clientid integer
);


ALTER TABLE public.reviews OWNER TO root;

--
-- Name: reviews_reviewid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.reviews_reviewid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_reviewid_seq OWNER TO root;

--
-- Name: reviews_reviewid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.reviews_reviewid_seq OWNED BY public.reviews.reviewid;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.suppliers (
    supplierid integer NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(50),
    typeofgoods character varying(255),
    contactperson character varying(255)
);


ALTER TABLE public.suppliers OWNER TO root;

--
-- Name: suppliers_supplierid_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.suppliers_supplierid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_supplierid_seq OWNER TO root;

--
-- Name: suppliers_supplierid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.suppliers_supplierid_seq OWNED BY public.suppliers.supplierid;


--
-- Name: clients clientid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.clients ALTER COLUMN clientid SET DEFAULT nextval('public.clients_clientid_seq'::regclass);


--
-- Name: dishes dishid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.dishes ALTER COLUMN dishid SET DEFAULT nextval('public.dishes_dishid_seq'::regclass);


--
-- Name: employees employeeid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.employees ALTER COLUMN employeeid SET DEFAULT nextval('public.employees_employeeid_seq'::regclass);


--
-- Name: ingredients ingredientid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.ingredients ALTER COLUMN ingredientid SET DEFAULT nextval('public.ingredients_ingredientid_seq'::regclass);


--
-- Name: orderdetails orderdetailid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orderdetails ALTER COLUMN orderdetailid SET DEFAULT nextval('public.orderdetails_orderdetailid_seq'::regclass);


--
-- Name: orders orderid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orders ALTER COLUMN orderid SET DEFAULT nextval('public.orders_orderid_seq'::regclass);


--
-- Name: restaurants restaurantid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN restaurantid SET DEFAULT nextval('public.restaurants_restaurantid_seq'::regclass);


--
-- Name: reviews reviewid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reviews ALTER COLUMN reviewid SET DEFAULT nextval('public.reviews_reviewid_seq'::regclass);


--
-- Name: suppliers supplierid; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplierid SET DEFAULT nextval('public.suppliers_supplierid_seq'::regclass);


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.clients (clientid, fullname, phone, foodpreferences) FROM stdin;
1	Василий Пупкин	123-456-7894	Любит мясо
2	Василий Пупкин	123-456-7894	Любит мясо
\.


--
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.dishes (dishid, name, description, price, category) FROM stdin;
1	Цезарь	Классический салат Цезарь	150.00	Салаты
2	Стейк	Стейк из мраморной говядины	350.00	Основные блюда
3	Цезарь	Классический салат Цезарь	150.00	Салаты
4	Стейк	Стейк из мраморной говядины	350.00	Основные блюда
\.


--
-- Data for Name: dishingredients; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.dishingredients (dishid, ingredientid) FROM stdin;
1	1
2	2
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.employees (employeeid, fullname, "position", salary, startdate, restaurantid) FROM stdin;
1	Анна Смирнова	Официант	25000.00	2023-01-01	1
2	Анна Смирнова	Официант	25000.00	2023-01-01	1
\.


--
-- Data for Name: ingredients; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.ingredients (ingredientid, name, cost, expirationdate, supplierid) FROM stdin;
1	Томаты	30.50	2023-12-31	1
2	Говядина	300.00	2023-12-31	2
3	Томаты	30.50	2023-12-31	1
4	Говядина	300.00	2023-12-31	2
\.


--
-- Data for Name: orderdetails; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.orderdetails (orderdetailid, orderid, dishid, quantity) FROM stdin;
7	4	1	2
8	4	2	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.orders (orderid, orderdate, tablenumber, totalamount, status, clientid) FROM stdin;
2	2023-12-01 19:00:00	5	500.00	В обработке	1
3	2023-01-01 18:00:00	1	500.00	В обработке	1
4	2023-01-01 18:00:00	1	500.00	В обработке	1
\.


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.restaurants (restaurantid, name, address, phone, operatinghours) FROM stdin;
1	Оазис	Улица Пушкина, 10	123-456-7890	10:00 - 22:00
2	Бистро	Проезд Лермонтова, 15	123-456-7891	09:00 - 20:00
3	Оазис	Улица Пушкина, 10	123-456-7890	10:00 - 22:00
4	Бистро	Проезд Лермонтова, 15	123-456-7891	09:00 - 20:00
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.reviews (reviewid, text, rating, reviewdate, clientid) FROM stdin;
1	Отличный ресторан, все понравилось	5	2023-12-01 20:00:00	1
2	Отличный ресторан, все понравилось	5	2023-12-01 20:00:00	1
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.suppliers (supplierid, name, phone, typeofgoods, contactperson) FROM stdin;
1	Овощи Круглый Год	123-456-7892	Овощи	Иван Иванов
2	Мясо Делюкс	123-456-7893	Мясо	Петр Петров
3	Овощи Круглый Год	123-456-7892	Овощи	Иван Иванов
4	Мясо Делюкс	123-456-7893	Мясо	Петр Петров
\.


--
-- Name: clients_clientid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.clients_clientid_seq', 2, true);


--
-- Name: dishes_dishid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.dishes_dishid_seq', 4, true);


--
-- Name: employees_employeeid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.employees_employeeid_seq', 2, true);


--
-- Name: ingredients_ingredientid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.ingredients_ingredientid_seq', 4, true);


--
-- Name: orderdetails_orderdetailid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.orderdetails_orderdetailid_seq', 8, true);


--
-- Name: orders_orderid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.orders_orderid_seq', 4, true);


--
-- Name: restaurants_restaurantid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.restaurants_restaurantid_seq', 4, true);


--
-- Name: reviews_reviewid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.reviews_reviewid_seq', 2, true);


--
-- Name: suppliers_supplierid_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.suppliers_supplierid_seq', 4, true);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (clientid);


--
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (dishid);


--
-- Name: dishingredients dishingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.dishingredients
    ADD CONSTRAINT dishingredients_pkey PRIMARY KEY (dishid, ingredientid);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employeeid);


--
-- Name: ingredients ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (ingredientid);


--
-- Name: orderdetails orderdetails_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_pkey PRIMARY KEY (orderdetailid);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (orderid);


--
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (restaurantid);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (reviewid);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplierid);


--
-- Name: ingredients check_ingredient_expiration; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER check_ingredient_expiration BEFORE INSERT OR UPDATE ON public.ingredients FOR EACH ROW EXECUTE FUNCTION public.check_expiration_date();


--
-- Name: orderdetails update_order_amount; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER update_order_amount AFTER INSERT OR UPDATE ON public.orderdetails FOR EACH ROW EXECUTE FUNCTION public.update_total_amount();


--
-- Name: dishingredients dishingredients_dishid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.dishingredients
    ADD CONSTRAINT dishingredients_dishid_fkey FOREIGN KEY (dishid) REFERENCES public.dishes(dishid);


--
-- Name: dishingredients dishingredients_ingredientid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.dishingredients
    ADD CONSTRAINT dishingredients_ingredientid_fkey FOREIGN KEY (ingredientid) REFERENCES public.ingredients(ingredientid);


--
-- Name: employees employees_restaurantid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_restaurantid_fkey FOREIGN KEY (restaurantid) REFERENCES public.restaurants(restaurantid);


--
-- Name: ingredients ingredients_supplierid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_supplierid_fkey FOREIGN KEY (supplierid) REFERENCES public.suppliers(supplierid);


--
-- Name: orderdetails orderdetails_dishid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_dishid_fkey FOREIGN KEY (dishid) REFERENCES public.dishes(dishid);


--
-- Name: orderdetails orderdetails_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orderdetails
    ADD CONSTRAINT orderdetails_orderid_fkey FOREIGN KEY (orderid) REFERENCES public.orders(orderid);


--
-- Name: orders orders_clientid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_clientid_fkey FOREIGN KEY (clientid) REFERENCES public.clients(clientid);


--
-- Name: reviews reviews_clientid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_clientid_fkey FOREIGN KEY (clientid) REFERENCES public.clients(clientid);


--
-- PostgreSQL database dump complete
--



#include "py4yap.h"
#include <frameobject.h>

void YAPPy_ThrowError__(const char *file, const char *function, int lineno,
                        yap_error_number type, term_t where, ...) {
  va_list ap;
  char tmpbuf[MAXPATHLEN];
  YAP_Term wheret = YAP_GetFromSlot(where);
  PyObject *ptype;

  if ((ptype = PyErr_Occurred()) == NULL) {
    PyErr_Print();
  }

  va_start(ap, where);
  char *format = va_arg(ap, char *);
  if (format != NULL) {
#if HAVE_VSNPRINTF
    (void)vsnprintf(tmpbuf, MAXPATHLEN - 1, format, ap);
#else
    (void)vsprintf(tnpbuf, format, ap);
#endif
    // fprintf(stderr, "warning: ");
    Yap_ThrowError__(file, function, lineno, type, wheret, tmpbuf);
  } else {
    Yap_ThrowError__(file, function, lineno, type, wheret);
  }
}

static foreign_t repr_term(PyObject *pVal, term_t t) {
  term_t to = PL_new_term_ref(), t1 = PL_new_term_ref();
  PL_put_pointer(t1, pVal);
  PL_cons_functor(to, FUNCTOR_pointer1, t1);
  Py_INCREF(pVal);
  return PL_unify(t, to);
}

foreign_t assign_to_symbol(term_t t, PyObject *e);

foreign_t assign_to_symbol(term_t t, PyObject *e) {
  char *s = NULL;
  if (!PL_get_atom_chars(t, &s)) {
    return false;
  }
  PyObject *dic;
  if (!lookupPySymbol(s, NULL, &dic))
    dic = py_Main;
  return PyObject_SetAttrString(dic, s, e) == 0;
}

foreign_t python_to_term(PyObject *pVal, term_t t) {
  bool rc = true;
  term_t to = PL_new_term_ref();
  // fputs(" <<***    ",stderr);  PyObject_Print(pVal,stderr,0);
  // fputs("<<***\n",stderr);
  if (pVal == Py_None) {
    // fputs("<<*** ",stderr);Yap_DebugPlWrite(YAP_GetFromSlot(t));   fputs("
    // >>***\n",stderr);
    rc = PL_unify_atom(t, ATOM_none);
    // fputs("<<*** ",stderr);Yap_DebugPlWrite(YAP_GetFromSlot(t));   fputs("
    // >>***\n",stderr);
  } else if (PyBool_Check(pVal)) {
    rc = rc && PL_unify_bool(t, PyObject_IsTrue(pVal));
  } else if (PyLong_Check(pVal)) {
    rc = rc && PL_unify_int64(t, PyLong_AsLong(pVal));
#if PY_MAJOR_VERSION < 3
  } else if (PyInt_Check(pVal)) {
    rc = rc && PL_unify_int64(t, PyInt_AsLong(pVal));
#endif
  } else if (PyFloat_Check(pVal)) {
    rc = rc && PL_unify_float(t, PyFloat_AsDouble(pVal));
  } else if (PyComplex_Check(pVal)) {
    term_t t1 = PL_new_term_ref(), t2 = PL_new_term_ref();
    if (!PL_put_float(t1, PyComplex_RealAsDouble(pVal)) ||
        !PL_put_float(t2, PyComplex_ImagAsDouble(pVal)) ||
        !PL_cons_functor(to, FUNCTOR_complex2, t1, t2)) {
      rc = false;
    } else {
      rc = rc && PL_unify(t, to);
    }
  } else if (PyUnicode_Check(pVal)) {
    atom_t tmp_atom;

#if PY_MAJOR_VERSION < 3
    size_t sz = PyUnicode_GetSize(pVal) + 1;
    wchar_t *ptr = malloc(sizeof(wchar_t) * sz);
    sz = PyUnicode_AsWideChar((PyUnicodeObject *)pVal, ptr, sz - 1);
    tmp_atom = PL_new_atom_wchars(sz, ptr);
    free(ptr);
#else
    const char *s = PyUnicode_AsUTF8(pVal);
    tmp_atom = PL_new_atom(s);
#endif
    rc = rc && PL_unify_atom(t, tmp_atom);
  } else if (PyByteArray_Check(pVal)) {
    atom_t tmp_atom = PL_new_atom(PyByteArray_AsString(pVal));
    rc = rc && PL_unify_atom(t, tmp_atom);
#if PY_MAJOR_VERSION < 3
  } else if (PyString_Check(pVal)) {
    atom_t tmp_atom = PL_new_atom(PyString_AsString(pVal));
    rc = rc && PL_unify_atom(t, tmp_atom);
#endif
  } else if (PyTuple_Check(pVal)) {
    Py_ssize_t i, sz = PyTuple_Size(pVal);
    functor_t f;
    const char *s;
    if (sz == 0) {
      rc = rc && PL_unify_atom(t, ATOM_brackets);
    } else {
      if ((s = (Py_TYPE(pVal)->tp_name))) {
        if (!strcmp(s, "v")) {
          pVal = PyTuple_GetItem(pVal, 0);
          if (pVal == NULL) {
            pVal = Py_None;
            PyErr_Clear();
          }
          term_t v = YAP_InitSlot(PyLong_AsLong(pVal));
          return PL_unify(v, t);
        }
        if (s[0] == '$') {
          char *ns = malloc(strlen(s) + 5);
          strcpy(ns, "__");
          strcat(ns, s + 1);
          strcat(ns, "__");
          f = PL_new_functor(PL_new_atom(ns), sz);
        } else {
          f = PL_new_functor(PL_new_atom(s), sz);
        }
      } else {
        f = PL_new_functor(ATOM_t, sz);
      }
      if (PL_unify_functor(t, f)) {
        for (i = 0; i < sz; i++) {
          if (!PL_get_arg(i + 1, t, to))
            rc = false;
          PyObject *p = PyTuple_GetItem(pVal, i);
          if (p == NULL) {
            PyErr_Clear();
            p = Py_None;
          }
          rc = rc && python_to_term(p, to);
        }
      } else {
        rc = false;
      }
      // fputs(" ||*** ",stderr); Yap_DebugPlWrite(YAP_GetFromSlot(t)); fputs("
      // ||***\n",stderr);
    }
  } else if (PyList_Check(pVal)) {
    Py_ssize_t i, sz = PyList_GET_SIZE(pVal);

    for (i = 0; i < sz; i++) {
      PyObject *obj;
      rc = rc && PL_unify_list(t, to, t);
      if ((obj = PyList_GetItem(pVal, i - 1)) == NULL) {
        obj = Py_None;
      }
      rc = rc && python_to_term(obj, to);
      if (!rc)
        return false;
    }
    return rc && PL_unify_nil(t);
    // fputs("[***]  ", stderr);
    // Yap_DebugPlWrite(yt); fputs("[***]\n", stderr);
  } else if (PyDict_Check(pVal)) {
    Py_ssize_t pos = 0;
    term_t to = PL_new_term_ref(), ti = to;
    int left = PyDict_Size(pVal);
    PyObject *key, *value;

    if (left == 0) {
      rc = rc && PL_unify_atom(t, ATOM_curly_brackets);
    } else {
      while (PyDict_Next(pVal, &pos, &key, &value)) {
        term_t tkey = PL_new_term_ref(), tval = PL_new_term_ref(), tint,
               tnew = PL_new_term_ref();
        /* do something interesting with the values... */
        if (!python_to_term(key, tkey)) {
          continue;
        }
        if (!python_to_term(value, tval)) {
          continue;
        }
        /* reuse */
        tint = tkey;
        if (!PL_cons_functor(tint, FUNCTOR_colon2, tkey, tval)) {
          rc = false;
          continue;
        }
        if (--left) {
          if (!PL_cons_functor(tint, FUNCTOR_comma2, tint, tnew))
            PL_reset_term_refs(tkey);
          rc = false;
        }
        if (!PL_unify(ti, tint)) {
          rc = false;
        }
        ti = tnew;
        PL_reset_term_refs(tkey);
      }
      rc = rc && PL_unify(t, to);
    }
  } else {
    rc = rc && repr_term(pVal, t);
  }
  PL_reset_term_refs(to);
  return rc;
}

X_API YAP_Term pythonToYAP(PyObject *pVal) {
  term_t t = PL_new_term_ref();
  if (pVal == NULL || !python_to_term(pVal, t)) {
    PL_reset_term_refs(t);
    return 0;
  }
  YAP_Term tt = YAP_GetFromSlot(t);
  PL_reset_term_refs(t);
  Py_DECREF(pVal);
  return tt;
}

PyObject *py_Local, *py_Global;

/**
 *   assigns the Python RHS to a Prolog term LHS, ie LHS = RHS
 *
 * @param root Python environment
 * @param t left hand side, in Prolog, may be
 *    - a Prolog variable, exports the term to Prolog, A <- RHS
 *    - Python variable A, A <- RHS
 *    - Python variable $A, A <- RHS
 *    - Python string "A", A <- RHS
 *    - Python array range
 * @param e the right-hand side
 *
 * @return -1 on failure.
 *
 * Note that this is an auxiliary routine to the Prolog
 *python_assign.
 */
bool python_assign(term_t t, PyObject *exp, PyObject *context) {
  context = find_obj(context, t, false);
  // Yap_DebugPlWriteln(yt);
  switch (PL_term_type(t)) {
  case PL_VARIABLE: {
    if (context == NULL) // prevent a.V= N*N[N-1]
      return python_to_term(exp, t);
  }

  case PL_ATOM: {
    char *s = NULL;
    PL_get_atom_chars(t, &s);
    if (!context)
      context = py_Main;
    if (PyObject_SetAttrString(context, s, exp) == 0)
      return true;
    PyErr_Print();
    return false;
  }
  case PL_STRING:
  case PL_INTEGER:
  case PL_FLOAT:
    // domain or type erro?
    return false;
  default: {
    term_t tail = PL_new_term_ref(), arg = PL_new_term_ref();
    size_t len, i;

    if (PL_is_pair(t)) {
      if (PL_skip_list(t, tail, &len) &&
          PL_get_nil(tail)) { //             true list

        if (PySequence_Check(exp) && PySequence_Length(exp) == len)

          for (i = 0; i < len; i++) {
            PyObject *p;
            if (!PL_get_list(t, arg, t)) {
              PL_reset_term_refs(tail);
              p = Py_None;
            }
            if ((p = PySequence_GetItem(exp, i)) == NULL)
              p = Py_None;
            if (!python_assign(arg, p, context)) {
              PL_reset_term_refs(tail);
            }
          }
      }
    } else {
      functor_t fun;

      if (!PL_get_functor(t, &fun)) {
        PL_reset_term_refs(tail);
        return false;
      }

      if (fun == FUNCTOR_sqbrackets2) {
        //  tail is the object o
        if (!PL_get_arg(2, t, tail)) {
          PL_reset_term_refs(tail);
          return false;
        }
        PyObject *o = term_to_python(tail, true, context, false);
        // t now refers to the index
        if (!PL_get_arg(1, t, t) || !PL_get_list(t, t, tail) ||
            !PL_get_nil(tail)) {
          PL_reset_term_refs(tail);
          return false;
        }
        PyObject *i = term_to_python(t, true, NULL, false);
        // check numeric
        if (PySequence_Check(o) && PyLong_Check(i)) {
          long int j;
          j = PyLong_AsLong(i);
          return PySequence_SetItem(o, j, exp) == 0;
        }
#if PY_MAJOR_VERSION < 3
        if (PySequence_Check(o) && PyInt_Check(i)) {
          long int j;
          j = PyInt_AsLong(i);
          return PySequence_SetItem(o, i, exp) == 0;
        }
#endif
        if (PyDict_Check(o)) {
          if (PyDict_SetItem(o, i, exp) == 0)
            return true;
        }
        if (PyObject_SetAttr(o, i, exp) == 0) {
          return true;
        }
      } else {
        atom_t s;
        int n, i;
        PL_get_name_arity(t, &s, &n);
        PyObject *o = term_to_python(t, true, context, true);
        if (PySequence_Check(o) && PySequence_Length(o) == n) {
          for (i = 1; i <= n; i++) {
            PyObject *p;
            if (!PL_get_arg(i, t, arg)) {
              PL_reset_term_refs(tail);
              o = false;
              p = Py_None;
            }
            if ((p = PySequence_GetItem(exp, i - 1)) == NULL)
              p = Py_None;
            else if (!python_assign(arg, p, NULL)) {
              PL_reset_term_refs(tail);
              o = NULL;
            }
          }
          return true;
        }
      }
    }
    PL_reset_term_refs(tail);
  }
    return NULL;
  }
}

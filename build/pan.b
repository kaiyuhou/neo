	switch (t->back) {
	default: Uerror("bad return move");
	case  0: goto R999; /* nothing to undo */

		 /* PROC :init: */

	case 3: // STATE 1
		;
		sv_restor();
;
		;
		goto R999;
;
		;
		
	case 5: // STATE 3
		;
		now.choice = trpt->bup.oval;
		;
		goto R999;
;
		;
		
	case 7: // STATE 5
		;
		now.choice = trpt->bup.oval;
		;
		goto R999;

	case 8: // STATE 10
		;
		sv_restor();
;
		;
		goto R999;

	case 9: // STATE 16
		;
		sv_restor();
;
		;
		goto R999;
;
		;
		
	case 11: // STATE 18
		;
		p_restor(II);
		;
		;
		goto R999;
	}


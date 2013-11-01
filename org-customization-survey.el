;; This function will report on the Org mode  customizations in your
;; running copy of Emacs and email the result to Mike McLean.
;;
;; I will report the results, in the aggregate, on the Org mode
;; mailing list to assist the Org developers in understanding what Org
;; features people use, and how they use them.
;;
;; To submit your results, evaluate and then execute this function.
;; The function will create its output in a buffer. If your Emacs is
;; configured for sending email, C-c C-c will send it.
;;
;; If your email is not configured for sending email, then manually
;; send the contents of the buffer to mike.mclean@pobox.com.


(defun org-customization-survey ()
  "Submit your Org mode customizations as part of an Org mode developer survey.

Don't hesitate to report any problems or inaccurate
documentation.

If you don't have setup sending mail from (X)Emacs, please copy the
output buffer into your mail program, as it gives us important
information about your Org-mode version and configuration."
  (interactive)
  (require 'reporter)
  (org-load-modules-maybe)
  (org-require-autoloaded-modules)
  (let ((reporter-prompt-for-summary-p "Just press enter: "))
    (reporter-submit-bug-report
     "mike.mclean@pobox.com"
     (org-version nil 'full)
     (let (list)
       (save-window-excursion
	 (org-pop-to-buffer-same-window (get-buffer-create "*Warn about privacy*"))
	 (delete-other-windows)
	 (erase-buffer)
	 (insert "You are about to submit your Org mode customization for a survey.

HOWEVER, some variables you have customized may contain private
information.  The names of customers, colleagues, or friends, might
appear in the form of file names, tags, todo states, or search strings.
you might want to check and remove such private information before
sending the email.  You will get a chance to edit before the mail will be
sent out.")
	 (add-text-properties (point-min) (point-max) '(face org-warning))
	 (when (yes-or-no-p "Include your Org-mode configuration ")
	   (mapatoms
	    (lambda (v)
	      (and (boundp v)
		   (string-match "\\`\\(org-\\|outline-\\)" (symbol-name v))
		   (or (and (symbol-value v)
			    (string-match "\\(-hook\\|-function\\)\\'" (symbol-name v)))
		       (and
			(get v 'custom-type) (get v 'standard-value)
			(not (equal (symbol-value v) (eval (car (get v 'standard-value)))))))
		   (push v list)))))
	 (kill-buffer (get-buffer "*Warn about privacy*"))
	 list))
     nil nil
     "Please check that this contains only stuff you want to share
for the survey.  Then send the email.  If your Emacs is configured for
sending email, C-c C-c is sufficient.  If not, mail the content
of the buffer to mike.mclean@pobox.com.
------------------------------------------------------------------------")
    (save-excursion
      (if (re-search-backward "^\\(Subject: \\)Org-mode version \\(.*?\\);[ \t]*\\(.*\\)" nil t)
	  (replace-match "\\1Customization survey submission")))))

;;; sickle.el.el --- sickle.el

;; Author: Gray King <grayking.w@gmail.com>
;; Version: 0.1.0

;;; Commentary:
;;

;;; TODO
;;

;;; Code:
;;
(require 'request)

(setq al '((a . b) (b . c)))
(cdr (assoc 'a al))

(defconst sickle-tt-fund-url "http://fundgz.1234567.com.cn/js/")

(defun show-item (obj key sep)
  "Show value from OBJ that store via KEY with a SEP."
  (let ((text (cdr (assoc key obj))))
    (let ((color-text (propertize text 'font-lock-faces '(:foreground-color "red"))))
      (princ (format "%s%s" color-text sep)))))

(defun sickle-parse-fund-json (json)
  "Parse JSON that responds via API."
  (let ((obj (json-read-from-string json)))
    (show-item obj 'fundcode "\t")
    (show-item obj 'dwjz "\t")
    (show-item obj 'jzrq "\t")
    (show-item obj 'gsz "\t")
    (show-item obj 'gszzl "\t")
    (show-item obj 'gztime "\t")
    (show-item obj 'name "\n")))

(defun sickle-parse-fund-detail (response)
  "Parse fund detail from JSONP in RESPONSE."

  (let ((data (request-response-data response)))
    (save-match-data
      (and (string-match "jsonpgz(\\(.+\\));" data)
           (let ((json (match-string 1 data)))
             (sickle-parse-fund-json json))))))

(defun sickle-fetch-fund (code)
  "Fetch fund detail via CODE."
  (request
    (s-concat sickle-tt-fund-url code ".js")
    :sync t
    :complete (cl-function
               (lambda (&key response &allow-other-keys)
                 (sickle-parse-fund-detail response)))))


(defvar sickle-fund-codes '("005827" "519674" "162703" "213001" "160618")
  "Fund codes to fetch.")

(defun sickle-show ()
  "Command to show fund detail."
  (interactive)
  (with-help-window "*sickle-fund*"
    (princ (format "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "基金代码" "单位净值" "净值日期" "估算值" "估算增长率" "估算时间" "基金名称"))
    (dolist (element sickle-fund-codes )
      (sickle-fetch-fund element))))

(global-set-key (kbd "C-c s f") 'sickle-show)
;;; sickle.el.el ends here

#!/usr/bin/env bash
# Simple GUI wrapper for check-generator.raku using zenity (Linux only)

if ! command -v zenity >/dev/null 2>&1; then
    zenity --error --text="zenity is not installed. Please install it (e.g., sudo apt-get install zenity)."
    exit 1
fi

if ! command -v raku >/dev/null 2>&1; then
    zenity --error --text="Raku is not installed or not in PATH."
    exit 1
fi

DATE_DEFAULT=$(date +%F)

FORM=$(zenity --forms --title="Raku Check Generator"     --text="Enter check details"     --add-entry="Date (default: $DATE_DEFAULT)"     --add-entry="Payee"     --add-entry="Amount (e.g. 123.45)"     --add-entry="Memo"     --add-entry="Signature text"     --add-entry="Routing number"     --add-entry="Account number"     --add-entry="Check number")

[ $? -ne 0 ] && exit 1

DATE=$(echo "$FORM" | cut -d'|' -f1)
PAYEE=$(echo "$FORM" | cut -d'|' -f2)
AMOUNT=$(echo "$FORM" | cut -d'|' -f3)
MEMO=$(echo "$FORM" | cut -d'|' -f4)
SIGNATURE=$(echo "$FORM" | cut -d'|' -f5)
ROUTING=$(echo "$FORM" | cut -d'|' -f6)
ACCOUNT=$(echo "$FORM" | cut -d'|' -f7)
CHECKNUM=$(echo "$FORM" | cut -d'|' -f8)

ARGS=()
[ -n "$DATE" ] && ARGS+=(--date="$DATE") || ARGS+=(--today)
[ -n "$PAYEE" ] && ARGS+=(--payee="$PAYEE")
[ -n "$AMOUNT" ] && ARGS+=(--amount="$AMOUNT")
[ -n "$MEMO" ] && ARGS+=(--memo="$MEMO")
[ -n "$SIGNATURE" ] && ARGS+=(--signature="$SIGNATURE")
[ -n "$ROUTING" ] && ARGS+=(--routing="$ROUTING")
[ -n "$ACCOUNT" ] && ARGS+=(--account="$ACCOUNT")
[ -n "$CHECKNUM" ] && ARGS+=(--check-num="$CHECKNUM")

# Always preview from GUI
ARGS+=(--preview)

raku check-generator.raku "${ARGS[@]}"

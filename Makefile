test:
	@cd backend && sh scripts/test.sh

lint:
	@cd backend && sh scripts/lint.sh

format:
	@cd backend && sh scripts/format.sh
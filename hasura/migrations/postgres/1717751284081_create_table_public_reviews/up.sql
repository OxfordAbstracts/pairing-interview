CREATE TABLE "public"."reviews" ("id" uuid NOT NULL DEFAULT gen_random_uuid(), "created_at" timestamptz NOT NULL DEFAULT now(), "updated_at" timestamptz NOT NULL DEFAULT now(), "reviewer_id" uuid NOT NULL, "abstract_id" uuid NOT NULL, "originality_score" integer, "interest_score" integer, "methodology_score" integer, "comments" text NOT NULL, PRIMARY KEY ("id") , FOREIGN KEY ("abstract_id") REFERENCES "public"."abstracts"("id") ON UPDATE restrict ON DELETE restrict, FOREIGN KEY ("reviewer_id") REFERENCES "public"."users"("id") ON UPDATE restrict ON DELETE restrict);
CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"()
RETURNS TRIGGER AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER "set_public_reviews_updated_at"
BEFORE UPDATE ON "public"."reviews"
FOR EACH ROW
EXECUTE PROCEDURE "public"."set_current_timestamp_updated_at"();
COMMENT ON TRIGGER "set_public_reviews_updated_at" ON "public"."reviews"
IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE EXTENSION IF NOT EXISTS pgcrypto;

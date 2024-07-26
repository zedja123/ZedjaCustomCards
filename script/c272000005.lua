local s,id,o=GetID()
function s.initial_effect(c)
	-- Rank-Up effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_XYZ_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end

function s.filter1(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end

function s.filter2(c,e,tp,mc)
	return c:IsSetCard(0x1048) or c:IsSetCard(0x1073) and c:IsRank(mc:GetRank()+1) and mc:IsCanBeXyzMaterial(c,tp)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCountFromEx(tp)>0
			and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_XYZ_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local mc=g1:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc)
		local sc=g2:GetFirst()
		if sc then
			Duel.Overlay(sc,Group.FromCards(mc))
			Duel.XyzSummon(tp,sc,nil)
		end
	end
end
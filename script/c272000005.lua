local s,id,o=GetID()
function s.initial_effect(c)
	-- Rank-Up effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- Effect 1: Banish from GY to look at opponent's Deck and Extra Deck, Special Summon 1 monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(2,id,EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end

function s.filter1(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return c:IsSetCard(0x1083) and not (c:IsSetCard(0x1073) or c:IsSetCard(0x1048)) and c:IsType(TYPE_XYZ) and (c:GetRank()>0 or c:IsStatus(STATUS_NO_LEVEL)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
end

function s.filter2(c,e,tp)
	return (c:IsSetCard(0x1073) or c:IsSetCard(0x1048)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.filter3(c,e,tp,mc)
	return c:IsRank(mc:GetRank()+1) and (c:IsSetCard(0x1073) or c:IsSetCard(0x1048)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local mc=g1:GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mc)
		local sc=g2:GetFirst()
		if sc then
			Duel.Overlay(sc,Group.FromCards(mc))
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end

function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA+LOCATION_DECK)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local gr=Duel.SelectMatchingCard(tp,s.spfilter,1-tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,TYPE_MONSTER,e,tp)
	local sg=gr:Select(tp,1,1,nil)
	local gf=sg:GetFirst()
		if gf:IsLinkMonster() then
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
			local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.GetLocationCountFromEx(1-tp,tp,nil,c)>0
			local op=0
			if b1 and b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			elseif b1 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2))
			elseif b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
			else return end
			if op==0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)
			else
				Duel.SpecialSummon(sg,0,tp,1-tp,true,true,POS_FACEUP)
			end
		elseif not gf:IsLinkMonster() then
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			local op=0
			if b1 and b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			elseif b1 then
				op=Duel.SelectOption(tp,aux.Stringid(id,2))
			elseif b2 then
				op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
			else return end
			if op==0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)
			else
				Duel.SpecialSummon(sg,0,tp,1-tp,true,true,POS_FACEUP)
			end
		end
		Duel.ShuffleDeck(1-tp)
		Duel.ShuffleExtra(1-tp)
end
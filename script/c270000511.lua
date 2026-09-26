--
--Milacresy Rakakeri
--scripted by Zedja
--revised by Whispered
local s,id=GetID()
local SET_MILACRESY=0xe05
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 "Milacresy" Tuner + 1 non-Tuner "Milacresy" monster
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MILACRESY),1,1,Synchro.NonTunerEx2(s.nontunerfilter),1,1,s.lnktunerfilter)
	--For this card's Synchro Summon, you can treat 1 "Milacresy" Link Monster you control as a Tuner with a Level equal to its Link Rating
	for lk=1,6 do
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetCode(EFFECT_SYNCHRO_LEVEL)
		e0:SetRange(LOCATION_EXTRA)
		e0:SetTargetRange(LOCATION_MZONE,0)
		e0:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) and c:IsLink(lk) end)
		e0:SetValue(lk)
		c:RegisterEffect(e0)
	end
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetTargetRange(LOCATION_MZONE,0)
	e0b:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) and c:IsLinkMonster() end)
	e0b:SetValue(function(e,sc) return sc and not sc:IsSetCard(SET_MILACRESY) end)
	c:RegisterEffect(e0b)
	--If this card is Synchro Summoned: You can banish the top 5 cards of your Deck, then you can Special Summon 1 "Milacresy" monster from your GY or banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--If you control no monsters, or all monsters you control are "Milacresy" monsters: You can shuffle 3 of your banished "Milacresy" cards into the Deck, then Special Summon this card from your GY, but banish it when it leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return not Duel.IsExistingMatchingCard(s.nonmilfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.gysptg)
	e2:SetOperation(s.gyspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MILACRESY}
function s.lnktunerfilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_MILACRESY,sc,sumtype,tp) and c:IsLinkMonster()
end
function s.nontunerfilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_MILACRESY,sc,sumtype,tp) and not c:IsLinkMonster()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDecktopGroup(tp,5):FilterCount(Card.IsAbleToRemove,nil)==5 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,5,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MILACRESY) and c:IsMonster() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g<5 then return end
	Duel.DisableShuffleCheck()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.nonmilfilter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_MILACRESY)
end
function s.tdfilter(c)
	return c:IsSetCard(SET_MILACRESY) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.gysptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.gyspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	if #g<3 then return end
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==3 and c:IsRelateToEffect(e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Banish it when it leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3300)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
			c:RegisterEffect(e1,true)
		end
	end
end

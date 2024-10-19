-- Milacresy Rakakeri
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon
	Synchro.AddProcedure(c,s.tunerfilter,1,1,s.nontunerfilter,1,1,Card.IsLinkMonster) -- "Milacresy" Tuner and non-Tuner
	c:EnableReviveLimit()
	-- Effect: Banish 5 cards and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- Description for effect
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.con)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

	-- Effect: Shuffle and Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1)) -- Description for the second effect
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,2})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

Card.IsCanBeSynchroMaterial=(function()
	local oldfunc=Card.IsCanBeSynchroMaterial
	return function(mc,sc)
		local res=oldfunc(mc,sc)
		return mc:IsLinkMonster() and sc:IsCode(270000511) or res
	end
end)()
Card.GetSynchroLevel=(function()
	local oldfunc=Card.GetSynchroLevel
	return function(mc,sc)
		if mc:IsLinkMonster() and sc:IsCode(270000511) then
			return mc:GetLink()
		end
		return oldfunc(mc,sc)
	end
end)()


function s.tunerfilter(c)
	return c:IsSetCard(0xf16) and c:IsType(TYPE_TUNER) -- "Milacresy" Tuner filter
end

function s.nontunerfilter(c)
	return c:IsSetCard(0xf16) and not c:IsType(TYPE_TUNER) -- "Milacresy" non-Tuner filter
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,5,nil) end
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,5)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsSetCard,nil,0xf16) -- Count "Milacresy" cards
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0xf16)==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) -- Check if all controlled monsters are "Milacresy"
end

function s.spfilter(c)
	return c:IsSetCard(0xf16) and c:IsCanBeSpecialSummoned() -- Filter for "Milacresy" cards to special summon
end

function s.shfilter(c)
	return c:IsSetCard(0xf16)-- Filter for "Milacresy" cards to special summon
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shfilter,tp,LOCATION_REMOVED,0,3,nil) end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		-- Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
--Milacresy Invallunism - Amarae
local s,id=GetID()
function c270000504.initial_effect(c)
	-- When Normal or Special Summoned
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SUMMON_SUCCESS)
e1:SetProperty(EFFECT_FLAG_DELAY)
e1:SetCountLimit(1,{id,1})
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e2)
	-- Quick effect during the Main Phase to restrict a monster's use as material
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE) -- Can be activated from the Monster Zone
	e3:SetCountLimit(1,{id,2}) -- Once per turn
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.matoperation)
	c:RegisterEffect(e3)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() -- Can only be activated during the Main Phase
end

function s.filter(c)
	return c:IsFaceup() -- Check for any face-up monster on the field
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.matoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- Prevent the target from being used as material until the end of the Chain
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetReset(RESET_CHAIN) -- Resets at the end of the Chain
		e1:SetValue(1)
		tc:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e2)

		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e3)

		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e4)
	end
end

-- Banish top 3 cards and Special Summon
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf16) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Duel.GetDecktopGroup(tp,3)
	Duel.DisableShuffleCheck()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
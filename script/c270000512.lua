--Milacresy Essence - Layah
local s,id,o=GetID()
function s.initial_effect(c)
	-- Synchro summon procedure
	Synchro.AddProcedure(c,s.tunerfilter,1,1,s.nontunerfilter,1,99,s.linkmonster) -- "Milacresy" Tuner and non-Tuner
	c:EnableReviveLimit()
		--Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	-- Look at the top 3 cards of your opponent's Deck and rearrange
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.syncon)
	e1:SetTarget(s.rearrangetg)
	e1:SetOperation(s.rearrangeop)
	c:RegisterEffect(e1)

	-- Quick Effect: Negate and destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
Card.IsCanBeSynchroMaterial=(function()
	local oldfunc=Card.IsCanBeSynchroMaterial
	return function(mc,sc)
		local res=oldfunc(mc,sc)
		return mc:IsLinkMonster() and sc:IsCode(270000512) or res
	end
end)()
Card.GetSynchroLevel=(function()
	local oldfunc=Card.GetSynchroLevel
	return function(mc,sc)
		if mc:IsLinkMonster() and sc:IsCode(270000512) then
			return mc:GetLink()
		end
		return oldfunc(mc,sc)
	end
end)()

function s.linkmonster(c)
	return c:IsControler(tp) and c:IsLinkMonster()
end
function s.tunerfilter(c)
	return c:IsSetCard(0xf16) and c:IsType(TYPE_TUNER) -- "Milacresy" Tuner filter
end

function s.nontunerfilter(c)
	return c:IsSetCard(0xf16) and not c:IsType(TYPE_TUNER) -- "Milacresy" non-Tuner filter
end
-- Synchro Summon condition
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Look at the top 3 cards of your opponent's Deck and rearrange
function s.rearrangetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
end
function s.rearrangeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(1-tp,3)
	if #g>0 then
		Duel.ConfirmDecktop(1-tp,3)
		local tg=g:Select(tp,3,3,nil)
		Duel.MoveSequence(tg:GetFirst(),0)
		Duel.MoveSequence(tg:GetNext(),1)
		Duel.MoveSequence(tg:GetNext(),2)
		Duel.DisableShuffleCheck()
	end
end

-- Negate and destroy
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.NegateRelatedChain(tc,RESET_TURN_SET) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- If you need additional effects upon destruction, you can add them here
		end
	end
end